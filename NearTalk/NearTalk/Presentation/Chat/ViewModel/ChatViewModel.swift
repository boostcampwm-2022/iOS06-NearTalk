//
//  ChatViewModel.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import Foundation
import RxRelay
import RxSwift

protocol ChatViewModelInput {
    func sendMessage(_ message: String)
}

protocol ChatViewModelOut {
    func getUserProfile(userID: String) -> UserProfile?
    var observeChatMessage: Observable<ChatMessage>? { get }
    var myID: String? { get }
    var chatRoom: BehaviorRelay<ChatRoom?> { get }
}

protocol ChatViewModel: ChatViewModelInput, ChatViewModelOut {
}

class DefaultChatViewModel: ChatViewModel {
    
    // MARK: - Proporties
    
    private let chatRoomID: String
    private var userUUIDList: [String]
    private var userProfileList: [String: UserProfile]
    private let disposeBag: DisposeBag = DisposeBag()
    var userChatRoomTicket: BehaviorRelay<UserChatRoomTicket?> = .init(value: nil)
    var userProfilesRely: BehaviorRelay<[UserProfile]?> = .init(value: nil)

    private var fetchChatRoomInfoUseCase: FetchChatRoomInfoUseCase
    private var messagingUseCase: MessagingUseCase
    private var userDefaultUseCase: UserDefaultUseCase
    private var fetchProfileUseCase: FetchProfileUseCase
    private var enterChatRoomUseCase: EnterChatRoomUseCase
    
    // MARK: - Outputs
    
    let chatRoom: BehaviorRelay<ChatRoom?> = .init(value: nil)
    var observeChatMessage: Observable<ChatMessage>?
    var myID: String?
    
    // MARK: - LifeCycle

    init(chatRoomID: String,
         fetchChatRoomInfoUseCase: FetchChatRoomInfoUseCase,
         userDefaultUseCase: UserDefaultUseCase,
         fetchProfileUseCase: FetchProfileUseCase,
         messagingUseCase: MessagingUseCase,
         enterChatRoomUseCase: EnterChatRoomUseCase
    ) {
        self.chatRoomID = chatRoomID
        self.messagingUseCase = messagingUseCase
        self.fetchChatRoomInfoUseCase = fetchChatRoomInfoUseCase
        self.userDefaultUseCase = userDefaultUseCase
        self.fetchProfileUseCase = fetchProfileUseCase
        self.enterChatRoomUseCase = enterChatRoomUseCase
        
        self.userProfileList = [:]
        self.userUUIDList = []
        
        self.myID = self.userDefaultUseCase.fetchUserUUID()
        
        // TODO: - 특정 갯수 만큼 메세지 가지고 올 수 있도록 변경
        self.observeChatMessage = self.messagingUseCase.observeMessage(roomID: self.chatRoomID)
        
        // TODO: - chatRoom 존재하지 않을때 예외처리
        // 1. chatroom single fetch
        // 2. 1번 성공시, myID를 chatRoom의 userUUIDList에 추가하기
        // 3. 1번 성공시, userProfiles fetch 해오기
        // 4. 1번 성공시, ticket 발급
        // 5. 4번 성공시, chatroom observe
        
        // 1.
        self.fetchChatRoomInfoUseCase.fetchChatRoomInfo(chatRoomID: self.chatRoomID)
            .do(onSuccess: { [weak self] chatRoom in
                guard let self = self,
                      let userUUIDList = chatRoom.userList,
                      let myID = self.myID
                else {
                    return
                }
                self.chatRoom.accept(chatRoom)
                self.userUUIDList = userUUIDList

                // 2.
                if !userUUIDList.contains(myID) {
                    self.userUUIDList.append(myID)
                    self.addUserInChatRoom(chatRoom: chatRoom, myID: myID)
                    self.updateUserProfile(userID: myID)
                }
                
                // 3.
                self.fetchUserProfiles(userUUIDList: self.userUUIDList)
            }, onError: { error in
                print("ERROR: chatRoom 가져오기 실패 ", error)
            })
            .subscribe(onSuccess: { [weak self] chatRoom in
                guard let self = self,
                    let myID = self.myID
                else {
                    return
                }
                // 4. UserChatRoomTicket 발급 및 업데이트
                self.configureUserChatRoomTicket(myID: myID, chatRoom: chatRoom)
            })
            .disposed(by: disposeBag)
            
        // 5. userChatRoomTicket 발급에 성공하면 chatRoom observe 시작
        self.userChatRoomTicket
            .flatMap({ _ in
                return self.fetchChatRoomInfoUseCase.observrChatRoomInfo(chatRoomID: self.chatRoomID)
            })
            .subscribe(onNext: { [weak self] chatRoom in
                guard let self else {
                    return
                }
                
                self.chatRoom.accept(chatRoom)
            })
            .disposed(by: self.disposeBag)
                
        // 메세지 송수신에 대한 userChatRoomTicket
        self.observeMessage()
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
            createdAt: Date()
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
                print(#function, "completed")
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: disposeBag)
    }
    
    func getUserProfile(userID: String) -> UserProfile? {
        print(userProfileList)
        return self.userProfileList[userID]
    }
}

private extension DefaultChatViewModel {
    func configureUserChatRoomTicket(myID: String, chatRoom: ChatRoom) {
        self.enterChatRoomUseCase.configureUserChatRoomTicket(userID: myID, chatRoom: chatRoom)
            .subscribe(onSuccess: { [weak self] ticket in
                guard let self else {
                    return
                }
                self.userChatRoomTicket.accept(ticket)
            }, onFailure: { error in
                print("ERROR: ", error)
            })
            .disposed(by: self.disposeBag)
    }
    
    func observeMessage() {
        self.observeChatMessage?
            .subscribe(onNext: { [weak self] chatMessage in
                guard let self,
                let messageCount = self.chatRoom.value?.messageCount else {
                    return
                }
                var newTicket = self.userChatRoomTicket.value
                newTicket?.lastReadMessageID = chatMessage.uuid
                newTicket?.lastRoomMessageCount = messageCount + 1
                
                if let newTicket {
                    self.enterChatRoomUseCase.updateUserChatRoomTicket(ticket: newTicket)
                        .subscribe(onSuccess: { _ in
                            print("newTicket 발급성공------------")
                        })
                        .disposed(by: self.disposeBag)
                }

                guard chatMessage.senderID == self.myID else {
                    return
                }
                
                var newChatRoom = self.chatRoom.value
                newChatRoom?.messageCount = messageCount + 1
                newChatRoom?.recentMessageID = chatMessage.uuid
                newChatRoom?.recentMessageDate = chatMessage.createdAt
                newChatRoom?.recentMessageText = chatMessage.text
                if let newChatRoom, let myID = self.myID {
                    _ = self.messagingUseCase.updateChatRoom(chatRoom: newChatRoom, userID: myID)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func addUserInChatRoom(chatRoom: ChatRoom, myID: String) {
        self.messagingUseCase.updateChatRoom(chatRoom: chatRoom, userID: myID)
            .subscribe(onCompleted: {
                print(#function, "onCompleted", myID)
            }, onError: { error in
                print(#function, "ERROR: ", error)
            }).disposed(by: self.disposeBag)
    }
    
    func fetchUserProfiles(userUUIDList: [String]) {
        self.fetchProfileUseCase.fetchUserProfiles(with: userUUIDList)
            .subscribe(onSuccess: { [weak self] userProfiles in
                guard let self else {
                    return
                }

                userProfiles.forEach { userProfile in
                    guard let uuid = userProfile.uuid else {
                        return
                    }
                    self.userProfileList[uuid] = userProfile
                }
            })
            .disposed(by: disposeBag)
    }
    
    func updateUserProfile(userID: String) {
        self.fetchProfileUseCase.fetchUserProfile(with: userID)
            .subscribe { [weak self] userProfile in
                guard let self,
                      userProfile.chatRooms?.contains(userID) == false
                else {
                    return
                }
                var newUserProfile = userProfile
                newUserProfile.chatRooms?.append(self.chatRoomID)
                self.fetchProfileUseCase.updateUserProfile(userProfile: newUserProfile)
            } onFailure: { error in
                print("ERROR: ", error)
            }
            .disposed(by: self.disposeBag)
    }
}
