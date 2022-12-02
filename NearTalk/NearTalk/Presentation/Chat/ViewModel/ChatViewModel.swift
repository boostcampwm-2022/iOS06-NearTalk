//
//  ChatViewModel.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import Foundation
import RxSwift
import RxRelay

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
    var userChatRoomTicket: BehaviorRelay<UserChatRoomTicket?> = .init(value: nil)
    
    // MARK: - Propoties
    private let chatRoomID: String
    let chatRoom: BehaviorRelay<ChatRoom?> = .init(value: nil)
    var myID: String?
    private var userUUIDList: [String]
    private var userProfileList: [String: UserProfile]
    private let disposebag: DisposeBag = DisposeBag()

    private var fetchChatRoomInfoUseCase: FetchChatRoomInfoUseCase
    private var messagingUseCase: MessagingUseCase
    private var userDefaultUseCase: UserDefaultUseCase
    private var fetchProfileUseCase: FetchProfileUseCase
    private var enterChatRoomUseCase: EnterChatRoomUseCase
    
    // MARK: - Ouputs
    var chatMessages: Observable<ChatMessage>
    
    // MARK: - LifeCycle
    // - 채팅방의 참가자 UUID가 있으니까 → fetch → VM
    // - 채팅방 정보를 Observe → 참가자 목록 변화 observe → 채팅방의 참가자 UUID가 있으니까 → fetch → VM
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
        
        self.userProfileList = [:]
        self.userUUIDList = []
        
        // 1. chatRoom
        self.fetchChatRoomInfoUseCase.fetchChatRoomInfo(chatRoomID: self.chatRoomID)
            .subscribe(onSuccess: { [weak self] chatRoom in
                guard let self = self,
                      let userUUIDList = chatRoom.userList,
                    let myID = self.myID
                else {
                    return
                }
                self.chatRoom.accept(chatRoom)
                self.userUUIDList = userUUIDList
                // 2. userUUIDList
                // myID를 chatRoom의 userUUIDList에 추가하기
                if !userUUIDList.contains(myID) {
                    print("~~~~~~~~~~~~~myID를 chatRoom의 userUUIDList에 추가하기", myID, userUUIDList)
                    self.userUUIDList.append(myID)
                    self.addUserInChatRoom(chatRoom: chatRoom, myID: myID)
                }
                
                // 3. userProfile
                self.fetchUserProfiles(userUUIDList: self.userUUIDList)
                
                // 4.
                self.enterChatRoom(myID: myID, chatRoom: chatRoom)
                
            })
            .disposed(by: disposebag)
        // TODO: - chatRoom 존재하지 않을때 예외처리
    }
    
    private func enterChatRoom(myID: String, chatRoom: ChatRoom) {
        self.enterChatRoomUseCase.enterChatRoom(userID: myID, chatRoom: chatRoom)
            .debug()
            .subscribe(onSuccess: { [weak self] ticket in
                print(ticket)
                guard let self,
                          let roomID = chatRoom.uuid else {
                              return
                          }
                self.userChatRoomTicket.accept(ticket)
                self.observeChatRoom(roomID: roomID)
            }, onError: { error in
                print(">>>>>", error)
            })
            .disposed(by: self.disposebag)
    }
    
    private func observeChatRoom(roomID: String) {
        self.fetchChatRoomInfoUseCase.observrChatRoomInfo(chatRoomID: roomID)
            .subscribe(onNext: { [weak self] chatRoom in
                guard let self else {
                    return
                }
                self.chatRoom.accept(chatRoom)
            })
            .disposed(by: self.disposebag)
        
    }
    
    private func observeMessage() {
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
                    _ = self.enterChatRoomUseCase.upateUserChatRoomTicket(ticket: newTicket)
                }
                
                guard chatMessage.senderID == self.myID else {
                    return
                }
                
                var newChatRoom = self.chatRoom.value
                newChatRoom?.messageCount = messageCount + 1
                newChatRoom?.recentMessageID = chatMessage.uuid
                newChatRoom?.recentMessageDate = chatMessage.createdDate
                newChatRoom?.recentMessageText = chatMessage.text
                if let newChatRoom, let myID = self.myID {
                    _ = self.messagingUseCase.updateChatRoom(chatRoom: newChatRoom, userID: myID)
                }
            })
            .disposed(by: self.disposebag)
    }
    
    private func addUserInChatRoom(chatRoom: ChatRoom, myID: String) {
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
            createdDate: Date()
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

struct MessageItem: Hashable {
    var id: String // message uuid
    var userName: String // sender name
    var message: String? // message text
    var type: MyMessageType // message Type
    var imagePath: String?
    var createdDate: Date
    
    init(chatMessage: ChatMessage, myID: String, userName: String?) {
        self.id = chatMessage.uuid ?? UUID().uuidString
        self.userName = userName  ?? "알수없음"
        self.message = chatMessage.text
        self.type = chatMessage.senderID == myID ? MyMessageType.send : MyMessageType.receive
        self.imagePath = chatMessage.mediaPath ?? "이미지없음"
        self.createdDate = chatMessage.createdDate ?? Date()
    }
}

enum MyMessageType: String {
    case send
    case receive
}
