//
// ChatViewModel.swift
// NearTalk
//
// Created by dong eun shin on 2022/11/23.
//

import Foundation
import RxRelay
import RxSwift

protocol ChatViewModelInput {
    func sendMessage(_ message: String)
    func viewWillDisappear()
    func dropRoom()
}

protocol ChatViewModelOutput {
    var myID: String? { get }
    var chatRoom: BehaviorRelay<ChatRoom?> { get }
    var chatMessages: BehaviorRelay<[ChatMessage]> { get }
    var lastUpdatedTimeOfTicketsRelay: BehaviorRelay<[String: Double]> { get }
    
    func getUserProfile(userID: String) -> UserProfile?
    func fetchMessages(before message: ChatMessage, isInitialMessage: Bool)
    var dropOutEvent: Observable<Bool> { get }
}

protocol ChatViewModel: ChatViewModelInput, ChatViewModelOutput { }

class DefaultChatViewModel: ChatViewModel {
    var dropOutEvent: Observable<Bool> {
        self.dropEvent.asObservable()
    }
    
    // MARK: - Proporties
    private let chatRoomID: String
    private var userUUIDList: [String]
    private var userProfileList: [String: UserProfile]
    private var messageCreatedTimeList: [String: Double]
    private var lastUpdatedTimeOfTickets: [String: Double]
    private var ticketList: [UserChatRoomTicket]
    
    private let fetchChatRoomInfoUseCase: FetchChatRoomInfoUseCase
    private let messagingUseCase: MessagingUseCase
    private let userDefaultUseCase: UserDefaultUseCase
    private let fetchProfileUseCase: FetchProfileUseCase
    private let enterChatRoomUseCase: EnterChatRoomUseCase
    private let dropChatRoomUseCase: DropChatRoomUseCase
    
    private let isLoading: BehaviorRelay<Bool> = .init(value: false)
    private let initialMessage: BehaviorRelay<ChatMessage?> = .init(value: nil)
    private let hasFirstMessage: BehaviorRelay<Bool> = .init(value: false)
    let userChatRoomTicket: BehaviorRelay<UserChatRoomTicket?> = .init(value: nil)
    let userProfilesRely: BehaviorRelay<[UserProfile]?> = .init(value: nil)
    let lastUpdatedTimeOfTicketsRelay: BehaviorRelay<[String: Double]> = .init(value: [:])
    private var disposeBag: DisposeBag = DisposeBag()
    private let dropEvent: PublishSubject<Bool> = PublishSubject()
    
    // MARK: - Output Proporties
    let chatRoom: BehaviorRelay<ChatRoom?>
    var chatMessages: BehaviorRelay<[ChatMessage]>
    var myID: String?
    
    // MARK: - LifeCycle
    init(
        chatRoomID: String,
        fetchChatRoomInfoUseCase: FetchChatRoomInfoUseCase,
        userDefaultUseCase: UserDefaultUseCase,
        fetchProfileUseCase: FetchProfileUseCase,
        messagingUseCase: MessagingUseCase,
        enterChatRoomUseCase: EnterChatRoomUseCase,
        dropChatRoomUseCase: DropChatRoomUseCase
    ) {
        self.messagingUseCase = messagingUseCase
        self.fetchChatRoomInfoUseCase = fetchChatRoomInfoUseCase
        self.userDefaultUseCase = userDefaultUseCase
        self.fetchProfileUseCase = fetchProfileUseCase
        self.enterChatRoomUseCase = enterChatRoomUseCase
        self.dropChatRoomUseCase = dropChatRoomUseCase
        
        self.chatRoomID = chatRoomID
        self.myID = self.userDefaultUseCase.fetchUserUUID()
        
        self.ticketList = []
        self.lastUpdatedTimeOfTickets = [:]
        self.messageCreatedTimeList = [:]
        self.userProfileList = [:]
        self.userUUIDList = []
        self.chatRoom = .init(value: nil)
        self.chatMessages = .init(value: [])
        
        self.initiateChatRoom()
        self.bindInitialMessage()
        // TODO: - chatRoom 존재하지 않을때 예외처리
    }
    
    func viewWillDisappear() {
        self.disposeBag = DisposeBag()
    }
    
    func sendMessage(_ message: String) {
        guard let chatRoomInfo = self.chatRoom.value,
              let roomName = chatRoomInfo.roomName,
              let chatRoomMemberIDList = chatRoomInfo.userList
        else {
            return
        }
        
        let chatMessage = ChatMessage(
            uuid: UUID().uuidString,
            chatRoomID: self.chatRoomID,
            senderID: self.myID,
            text: message,
            messageType: MessageType.text.rawValue,
            mediaPath: nil,
            mediaType: nil,
            createdAtTimeStamp: Date().timeIntervalSince1970
        )
        
        self.messagingUseCase.sendMessage(
            message: chatMessage,
            roomID: self.chatRoomID,
            roomName: roomName,
            chatMemberIDList: chatRoomMemberIDList
        )
        .subscribe { event in
            switch event {
            case .completed:
                print("🚧 ", #function, "completed")
            case .error(let error):
                print("🚧 ", #function, error)
            }
        }
        .disposed(by: self.disposeBag)
    }
    
    func getUserProfile(userID: String) -> UserProfile? {
        return self.userProfileList[userID]
    }
    
    func dropRoom() {
        guard let myID = self.myID
        else {
            return
        }

        self.dropChatRoomUseCase.execute(myID, self.chatRoomID)
            .subscribe(onCompleted: { [weak self] in
                self?.dropEvent.onNext(true)
            }, onError: { [weak self] error in
                self?.dropEvent.onNext(false)
            }).disposed(by: self.disposeBag)
    }
}

/*
 1. 채팅방 정보 불러오기
    1-1. 채팅방 참가자 프로필 리스트 불러오기
    (입장한 적 없는 채팅방이라면)
    1-2. 채팅방에 내 프로필 추가
    1-3. 내 프로필에 채팅방 추가
 
 2. 새로운 메세지 observe (특이사항: 가장 최근 메세지 1개가 불러와진다.)
    2-1. 채팅방 정보 observe
 */
// MARK: - Initiate ChatViewModel
extension DefaultChatViewModel {
    private func initiateChatRoom() {
        self.fetchChatRoomInfo()
            .flatMapCompletable { [weak self] (uuidList: [String]) in
                guard let self
                else {
                    return Completable.error(ChatViewModelError.failedToFetch)
                }
                return self.fetchChatRoomUserProfileList(uuidList)
            }
            .andThen(self.isVisitedChatRoom(self.chatRoomID))
            .flatMapCompletable { [weak self] isVisited in
                guard let self
                else {
                    return Completable.error(ChatViewModelError.failedToFetchProfile)
                }
                
                if !isVisited {
                    return self.updateInfo()
                } else {
                    return self.configureUserChatRoomTicket()
                }
            }
            .subscribe(onCompleted: { [weak self] in
                self?.observeNewMessage()
                self?.observeChatRoom()
                self?.bindNewMessage()
            }).disposed(by: self.disposeBag)
    }
    
    private func observeNewMessage() {
        self.messagingUseCase.observeMessage(roomID: self.chatRoomID)
            .subscribe(onNext: { [weak self] message in
                guard let self,
                      let messageCount = self.chatRoom.value?.messageCount,
                      let createdAtTimeStamp = message.createdAtTimeStamp,
                      let messageID = message.uuid else {
                    return
                }
                
                if self.initialMessage.value == nil {
                    self.initialMessage.accept(message)
                    return
                } else {
                    self.updateTicketAndChatRoom(message, messageCount)
                }
                
                var newChatMessages: [ChatMessage] = self.chatMessages.value
                newChatMessages.append(message)
                newChatMessages.sort(by: { $0.createdAtTimeStamp! < $1.createdAtTimeStamp! })
                ///
                self.messageCreatedTimeList[messageID] = createdAtTimeStamp
                ///
                self.chatMessages.accept(newChatMessages)
            }).disposed(by: self.disposeBag)
    }
    
    private func observeChatRoom() {
        self.fetchChatRoomInfoUseCase.observeChatRoomInfo(chatRoomID: self.chatRoomID)
            .subscribe(onNext: { [weak self] chatRoom in
                guard let self,
                      let userList: [String] = self.chatRoom.value?.userList,
                      let newUserList: [String] = chatRoom.userList
                else {
                    return
                }
                self.chatRoom.accept(chatRoom)
                
                let userSet: Set<String> = Set(userList)
                let newUserSet: Set<String> = Set(newUserList)
                if userSet.union(newUserSet).count == userSet.count {
                    return
                }
                
                self.userUUIDList = newUserList
                self.fetchChatRoomUserProfileList(newUserList).subscribe(onCompleted: {
                    print("🚧 user list is modified")
                }).dispose()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func fetchChatRoomInfo() -> Single<[String]> {
        self.fetchChatRoomInfoUseCase.fetchChatRoomInfo(chatRoomID: self.chatRoomID)
            .flatMap { [weak self] chatRoom in
                guard let self,
                      let userUUIDList: [String] = chatRoom.userList
                else {
                    return .error(ChatViewModelError.failedToFetch)
                }
                self.chatRoom.accept(chatRoom)
                self.userUUIDList = userUUIDList
                return .just(userUUIDList)
            }
    }
    
    private func fetchChatRoomUserProfileList(_ userUUIDList: [String]) -> Completable {
        self.fetchProfileUseCase.fetchUserProfiles(with: userUUIDList)
            .do(onSuccess: { [weak self] userProfiles in
                guard let self
                else {
                    return
                }
                userProfiles.forEach { userProfile in
                    guard let uuid = userProfile.uuid
                    else {
                        return
                    }
                    self.userProfileList[uuid] = userProfile
                }
            })
            .asCompletable()
    }
    
    private func fetchUserChatRoomTicketList(_ userUUIDList: [String]) -> Completable {
        self.enterChatRoomUseCase.fetchSingleUserChatRoomTickets(
            userIDList: userUUIDList.last!,
            chatRoomID: self.chatRoomID
        )
        .do(onSuccess: { [weak self] ticket in
            guard let self else {
                return
            }
            
            self.ticketList = [ticket]
        })
        .asCompletable()
    }
    
    private func isVisitedChatRoom(_ roomID: String) -> Single<Bool> {
        Single<Bool>.create { [weak self] single in
            guard let self
            else {
                single(.failure(ChatViewModelError.failedToFetchProfile))
                return Disposables.create()
            }
            single(.success(self.isVisitedChatRoom(roomID)))
            return Disposables.create()
        }
    }
    
    private func isVisitedChatRoom(_ roomID: String) -> Bool {
        guard let myProfile: UserProfile = userDefaultUseCase.fetchUserProfile(),
              let visitedChatRoom: [String] = myProfile.chatRooms
        else {
            print("🔴 프로필이 등록되지 않았음.")
            return false
        }
        return visitedChatRoom.contains(roomID)
    }
    
    private func updateInfo() -> Completable {
        Completable.zip(
            self.updateProfileWithNewChatRoom(),
            self.updateChatRoomWithNewUser(),
            self.configureUserChatRoomTicket()
        )
    }
    
    private func updateChatRoomWithNewUser() -> Completable {
        guard let myID,
              let chatRoom: ChatRoom = self.chatRoom.value
        else {
            return Completable.error(ChatViewModelError.failedToFetch)
        }
        return self.messagingUseCase.updateChatRoom(chatRoom: chatRoom, userID: myID)
    }
    
    private func updateProfileWithNewChatRoom() -> Completable {
        self.fetchProfileUseCase.fetchMyProfile()
            .flatMapCompletable({ [weak self] userProfile in
                guard let self,
                      let hasChatRoom: Bool = userProfile.chatRooms?.contains(self.chatRoomID)
                else {
                    return Completable.error(ChatViewModelError.failedToFetch)
                }
                
                if hasChatRoom {
                    return Completable.empty()
                }
                
                var newUserProfile = userProfile
                newUserProfile.chatRooms?.append(self.chatRoomID)
                
                return self.fetchProfileUseCase.updateUserProfileCompletable(userProfile: newUserProfile)
            })
    }
    
    private func configureUserChatRoomTicket() -> Completable {
        guard let myID,
              let chatRoom = self.chatRoom.value
        else {
            return Completable.error(ChatViewModelError.failedToFetchChatRoom)
        }
        
        return self.enterChatRoomUseCase
            .configureUserChatRoomTicket(userID: myID, chatRoom: chatRoom)
            .do(onSuccess: { [weak self] (ticket: UserChatRoomTicket) in
                guard let self
                else {
                    return
                }
                self.userChatRoomTicket.accept(ticket)
            })
            .asCompletable()
    }
    
    private func updateTicketAndChatRoom(_ message: ChatMessage, _ messageCount: Int) {
        Completable.zip([
            self.updateTicketWithNewMessage(message, messageCount),
            self.updateChatRoomWithNewMessage(message, messageCount)
        ])
        .subscribe(
            onCompleted: {
                print("[🚧 success] to update chatRoom and ticket")
            }, onError: { error in
                print("[🚧 error]", error)
            }
        ).dispose()
    }
    
    private func updateTicketWithNewMessage(_ message: ChatMessage, _ messageCount: Int) -> Completable {
        guard var newTicket: UserChatRoomTicket = self.userChatRoomTicket.value
        else {
            return Completable.error(ChatViewModelError.failedToFetchTicket)
        }
        
        newTicket.lastReadMessageID = message.uuid
        newTicket.lastRoomMessageCount = messageCount + 1
        
        return self.enterChatRoomUseCase
            .updateUserChatRoomTicket(ticket: newTicket)
            .asCompletable()
    }
    
    private func updateChatRoomWithNewMessage(_ message: ChatMessage, _ messageCount: Int) -> Completable {
        guard let myID,
              message.senderID == myID,
              var newChatRoom = self.chatRoom.value
        else {
            return Completable.error(ChatViewModelError.failedToFetch)
        }
        newChatRoom.messageCount = messageCount + 1
        newChatRoom.recentMessageID = message.uuid
        newChatRoom.recentMessageDateTimeStamp = message.createdAtTimeStamp
        newChatRoom.recentMessageText = message.text
        
        return messagingUseCase.updateChatRoom(chatRoom: newChatRoom, userID: myID)
    }
    
    private func bindNewMessage() {
        self.chatMessages
            .flatMap({ [weak self] (chatMessages: [ChatMessage]) in
                guard let self,
                let lastMessage = chatMessages.last,
                let messageCount = self.chatRoom.value?.messageCount else {
                    return Completable.error(ChatViewModelError.failedToObserve)
                }
                return self.updateTicketWithNewMessage(lastMessage, messageCount)
            })
            .subscribe(onCompleted: {
                print("성공")
            })
            .disposed(by: self.disposeBag)
    }
    
    func fetchMessages() -> Single<[ChatMessage]> {
        return .error(NSError())
    }
}

// MARK: - Fetch messages
extension DefaultChatViewModel {
    func bindInitialMessage() {
        self.initialMessage
            .subscribe(onNext: { [weak self] (message: ChatMessage?) in
                guard let self,
                      let message,
                      let messageID = message.uuid,
                      let createdAtTimeStamp = message.createdAtTimeStamp,
                      let chatRoom = self.chatRoom.value else {
                    return
                }
                ///
                self.messageCreatedTimeList[messageID] = createdAtTimeStamp
                ///
                self.fetchMessages(before: message, isInitialMessage: true)
                
                self.fetchChatRoomInfoUseCase.fetchParticipantTickets(chatRoom)
                    .subscribe(onNext: { ticketList in
                        print(">>>>>")
                        ticketList.forEach { [weak self] ticket in
                            guard let self,
                                  let ticketID = ticket.uuid,
                                let lastReadMessageID = ticket.lastReadMessageID
                            else {
                                return
                            }
                            self.lastUpdatedTimeOfTickets[ticketID] = self.messageCreatedTimeList[lastReadMessageID]
                        }
                        print(self.lastUpdatedTimeOfTickets)
                        self.lastUpdatedTimeOfTicketsRelay.accept(self.lastUpdatedTimeOfTickets)
                    })
                    .disposed(by: self.disposeBag)
            }).disposed(by: self.disposeBag)
    }
    
    func fetchMessages(before message: ChatMessage, isInitialMessage: Bool = false) {
        guard !self.hasFirstMessage.value,
              !self.isLoading.value
        else {
            return
        }
        
        self.isLoading.accept(true)
        self.messagingUseCase.fetchMessage(
            before: message,
            roomID: self.chatRoomID,
            totalMessageCount: 30
        )
        .subscribe(
            onSuccess: { [weak self] messages in
                guard let self
                else {
                    self?.isLoading.accept(false)
                    return
                }
                
                print("🚧 ", messages.count)
                
                if messages.count == 0 {
                    self.hasFirstMessage.accept(true)
                }
                
                var newValue: [ChatMessage] = self.chatMessages.value
                if isInitialMessage {
                    newValue = messages + [message]
                } else {
                    newValue = messages + newValue
                }
                
                newValue.forEach { message in
                    guard let createdAtTimeStamp = message.createdAtTimeStamp,
                    let uuid = message.uuid else {
                        return
                    }
                    self.messageCreatedTimeList[uuid] = createdAtTimeStamp
                }
                newValue.sort(by: { $0.createdAtTimeStamp! < $1.createdAtTimeStamp! })
                
                self.chatMessages.accept(newValue)
                self.isLoading.accept(false)
            },
            onFailure: { [weak self] error in
                guard let self
                else {
                    return
                }
                print("🚧 ", #function, error)
                self.isLoading.accept(false)
            }
        )
        .disposed(by: self.disposeBag)
    }
    
    private func fetch(userUUIDList: [String]) -> Completable {
        Completable.zip([
            fetchChatRoomUserProfileList(userUUIDList),
            fetchUserChatRoomTicketList(userUUIDList)
        ])
    }
}

// MARK: - ChatViewModel Error
enum ChatViewModelError: Error {
    case failedToFetch
    case failedToFetchID
    case failedToFetchProfile
    case failedToFetchChatRoom
    case failedToFetchTicket
    case failedToObserve
}
