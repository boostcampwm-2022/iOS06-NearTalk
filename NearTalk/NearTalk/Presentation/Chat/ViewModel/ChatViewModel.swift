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
    var chatMessages: Observable<ChatMessage> { get }
    var myID: String? { get }
    var chatRoom: BehaviorRelay<ChatRoom?> { get }
}

protocol ChatViewModel: ChatViewModelInput, ChatViewModelOut {
}

class DefaultChatViewModel: ChatViewModel {
    
    // MARK: - Propoties
    
    private let chatRoomID: String
    private var userUUIDList: [String]
    private var userProfileList: [String: UserProfile]
    private let disposebag: DisposeBag = DisposeBag()
    var userChatRoomTicket: BehaviorRelay<UserChatRoomTicket?> = .init(value: nil)

    private var fetchChatRoomInfoUseCase: FetchChatRoomInfoUseCase
    private var messagingUseCase: MessagingUseCase
    private var userDefaultUseCase: UserDefaultUseCase
    private var fetchProfileUseCase: FetchProfileUseCase
    private var enterChatRoomUseCase: EnterChatRoomUseCase
    
    // MARK: - Ouputs
    
    let chatRoom: BehaviorRelay<ChatRoom?> = .init(value: nil)
    var chatMessages: Observable<ChatMessage>
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
        
        self.myID = self.userDefaultUseCase.fetchUserUUID()
        
        self.chatMessages = self.messagingUseCase.observeMessage(roomID: self.chatRoomID)
//            .map({ chatMessage in
//                let userProfile = self.getUserProfile(userID: message.senderID ?? "")
//                return MessageItem(chatMessage: chatMessage, myID: self.myID ?? "", userName: userProfile)
//            })
        
        self.userProfileList = [:]
        self.userUUIDList = []
        
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
            .disposed(by: disposebag)
            
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
            .disposed(by: self.disposebag)
        
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
                print("message sending completed")
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: disposebag)
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
            .disposed(by: self.disposebag)
    }
    
    func observeMessage() {
        self.chatMessages
            .subscribe(onNext: { [weak self] chatMessage in
                guard let self,
                let messageCount = self.chatRoom.value?.messageCount else {
                    return
                }
                var newTicket = self.userChatRoomTicket.value
                newTicket?.lastReadMessageID = chatMessage.uuid
                newTicket?.lastRoomMessageCount = messageCount + 1
                
                if let newTicket {
                    self.enterChatRoomUseCase.upateUserChatRoomTicket(ticket: newTicket)
                        .subscribe(onSuccess: { _ in
                            print("newTicket------------")
                        })
                        .disposed(by: self.disposebag)
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
            .disposed(by: self.disposebag)
    }
    
    func addUserInChatRoom(chatRoom: ChatRoom, myID: String) {
        self.messagingUseCase.updateChatRoom(chatRoom: chatRoom, userID: myID)
            .subscribe {
                print("addUserInChatRoom 성공", myID)
            } onError: { error in
                print("addUserInChatRoom 씰패", error)
            }.disposed(by: self.disposebag)
    }
    
    private func fetchUserProfiles(userUUIDList: [String]) {
        userUUIDList.forEach {
            self.fetchProfileUseCase.fetchUserInfo(with: $0)
                .subscribe { [weak self] userProfile in
                    guard let self = self,
                          let uuid = userProfile.uuid
                    else {
                        return
                    }
                    self.userProfileList[uuid] = userProfile
                } onFailure: { error in
                    print("ERROR: ", error)
                }
                .disposed(by: self.disposebag)
        }
    }
    
    private func updateUserProfile(userID: String) {
        self.fetchProfileUseCase.fetchUserInfo(with: userID)
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
            .disposed(by: self.disposebag)
    }
}
