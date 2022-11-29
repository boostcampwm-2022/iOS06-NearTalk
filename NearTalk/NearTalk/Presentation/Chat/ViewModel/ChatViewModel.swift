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
}

protocol ChatViewModel: ChatViewModelInput, ChatViewModelOut {
}

class DefaultChatViewModel: ChatViewModel {
    
    // MARK: - Propoties
    private let chatRoomID: String
    private let chatRoomName: String
    private var chatroomMemberUUIDList: [String]
    private let disposebag: DisposeBag = DisposeBag()
    
    private var messagingUseCase: MessagingUseCase
    var chatMessages: Observable<ChatMessage>
    
    // MARK: - LifeCycle
    init(chatRoomID: String, chatRoomName: String, chatRoomMemberUUIDList: [String], messagingUseCase: MessagingUseCase) {
        self.chatRoomID = chatRoomID
        self.chatRoomName = chatRoomName
        self.chatroomMemberUUIDList = chatRoomMemberUUIDList
        self.messagingUseCase = messagingUseCase
        self.chatMessages = self.messagingUseCase.observeMessage(roomID: self.chatRoomID)
    }
        
    func sendMessage(_ message: String) {
        print(#function, message)
        
        let chatMessage = ChatMessage(
            uuid: UUID().uuidString,
            chatRoomID: self.chatRoomID,
            senderID: "532BEDF5-F47C-4D83-A60E-539075D257E0", // 임시 ID - userdefault에 저장된 값 사용 예정
            text: message,
            messageType: MessageType.text.rawValue,
            mediaPath: nil,
            mediaType: nil,
            createdDate: Date()
        )
        
        self.messagingUseCase.sendMessage(
            message: chatMessage,
            roomID: self.chatRoomID,
            roomName: self.chatRoomName,
            chatMemberIDList: self.chatroomMemberUUIDList
        )
        .subscribe { event in
            switch event {
            case .completed:
                print(">>>>>>>>>>message sending completed")
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: disposebag)
    }
}
