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
    var chatMessages: Observable<ChatMessage> { get }
    var chatRoomInfo: Observable<ChatRoom> { get }
    var senderID: String? { get }
}

protocol ChatViewModel: ChatViewModelInput, ChatViewModelOut {
}

class DefaultChatViewModel: ChatViewModel {
    
    // MARK: - Propoties
    private let chatRoomID: String
    private var chatRoom: ChatRoom?
    private let disposebag: DisposeBag = DisposeBag()

    private var fetchChatRoomInfoUseCase: FetchChatRoomInfoUseCase
    private var messagingUseCase: MessagingUseCase
    private var userDefaultUseCase: UserDefaultUseCase
    
    // MARK: - Ouputs
    var chatMessages: Observable<ChatMessage>
    var chatRoomInfo: Observable<ChatRoom>
    var senderID: String?
    
    // MARK: - LifeCycle
    
    init(chatRoomID: String,
         fetchChatRoomInfoUseCase: FetchChatRoomInfoUseCase,
         userDefaultUseCase: UserDefaultUseCase,
         messagingUseCase: MessagingUseCase
    ) {
        self.chatRoomID = chatRoomID
        self.messagingUseCase = messagingUseCase
        self.fetchChatRoomInfoUseCase = fetchChatRoomInfoUseCase
        self.userDefaultUseCase = userDefaultUseCase
        self.senderID = self.userDefaultUseCase.fetchUserUUID()
        
        self.chatMessages = self.messagingUseCase.observeMessage(roomID: self.chatRoomID)
        self.chatRoomInfo = self.fetchChatRoomInfoUseCase.observrChatRoomInfo(chatRoomID: self.chatRoomID)
        
        self.chatRoomInfo
            .subscribe(onNext: { [weak self] chatRoom in
                self?.chatRoom = chatRoom
            })
            .disposed(by: disposebag)
    }
        
    func sendMessage(_ message: String) {
        guard let chatRoomInfo = self.chatRoom,
              let roomName = chatRoomInfo.roomName,
              let chatRoomMemberIDList = chatRoomInfo.userList,
              let senderID = self.senderID
        else {
            return
        }
        
        let chatMessage = ChatMessage(
            uuid: UUID().uuidString,
            chatRoomID: self.chatRoomID,
            senderID: senderID,
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
}
