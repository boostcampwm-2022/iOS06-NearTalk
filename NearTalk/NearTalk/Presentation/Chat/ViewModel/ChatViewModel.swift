//
//  ChatViewModel.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import Foundation
import RxSwift

protocol ChatViewModelInput {
    func sendMessage(_ message: String)
}

protocol ChatViewModelOut {
    func getUserProfile(userID: String) -> UserProfile?
    var chatMessages: Observable<ChatMessage> { get }
    var chatRoomInfo: Observable<ChatRoom> { get }
    var myID: String? { get }
}

protocol ChatViewModel: ChatViewModelInput, ChatViewModelOut {
}

class DefaultChatViewModel: ChatViewModel {
    
    // MARK: - Propoties
    private let chatRoomID: String
    private var chatRoom: ChatRoom?
    var myID: String?
    private var userUUIDList: [String]
    private var userProfileList: [String: UserProfile]
    private let disposebag: DisposeBag = DisposeBag()

    private var fetchChatRoomInfoUseCase: FetchChatRoomInfoUseCase
    private var messagingUseCase: MessagingUseCase
    private var userDefaultUseCase: UserDefaultUseCase
    private var fetchProfileUseCase: FetchProfileUseCase
    
    // MARK: - Ouputs
    var chatMessages: Observable<ChatMessage>
    var chatRoomInfo: Observable<ChatRoom>
    
    // MARK: - LifeCycle
    // - 채팅방의 참가자 UUID가 있으니까 → fetch → VM
    // - 채팅방 정보를 Observe → 참가자 목록 변화 observe → 채팅방의 참가자 UUID가 있으니까 → fetch → VM
    init(chatRoomID: String,
         fetchChatRoomInfoUseCase: FetchChatRoomInfoUseCase,
         userDefaultUseCase: UserDefaultUseCase,
         fetchProfileUseCase: FetchProfileUseCase,
         messagingUseCase: MessagingUseCase
    ) {
        self.chatRoomID = chatRoomID
        self.messagingUseCase = messagingUseCase
        self.fetchChatRoomInfoUseCase = fetchChatRoomInfoUseCase
        self.userDefaultUseCase = userDefaultUseCase
        self.fetchProfileUseCase = fetchProfileUseCase
        self.myID = self.userDefaultUseCase.fetchUserUUID()
        
        self.chatMessages = self.messagingUseCase.observeMessage(roomID: self.chatRoomID)
        
        self.chatRoomInfo = self.fetchChatRoomInfoUseCase.observrChatRoomInfo(chatRoomID: self.chatRoomID)
        self.userProfileList = [:]
        self.userUUIDList = []
        // 1. chatRoom
        self.chatRoomInfo
            .subscribe(onNext: { [weak self] chatRoom in
                guard let self = self,
                      let userUUIDList = chatRoom.userList,
                    let myID = self.myID
                else {
                    return
                }
                self.chatRoom = chatRoom
                self.userUUIDList = userUUIDList
                // 2. userUUIDList
                // myID를 chatRoom의 userUUIDList에 추가하기
                if !userUUIDList.contains(myID) {
                    print("~~~~~~~~~~~~~myID를 chatRoom의 userUUIDList에 추가하기", myID, userUUIDList)
                    self.messagingUseCase.addUserInChatRoom(chatRoom: chatRoom, userID: myID)
                        .subscribe {
                            self.userUUIDList.append(myID)
                            print("addUserInChatRoom 성공")
                        } onError: { error in
                            print("addUserInChatRoom 씰패", error)
                        }.disposed(by: self.disposebag)

                }
                
               // 3. userProfile
                self.userUUIDList.forEach {
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
            })
            .disposed(by: disposebag)
    }
        
    func sendMessage(_ message: String) {
        guard let chatRoomInfo = self.chatRoom,
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
