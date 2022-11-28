//
//  MessagingUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/24.
//

import Foundation
import RxSwift

protocol MessagingUseCase {
    func sendMessage(message: ChatMessage, roomName: String) -> Completable
    func observeMessage(roomID: String) -> Observable<ChatMessage>
}

final class DefalultMessagingUseCase: MessagingUseCase {
    // MARK: - Proporty
    
    private let chatMessageRepository: ChatMessageRepository
    
    // MARK: - LifeCycle
    
    init(chatMessageRepository: ChatMessageRepository) {
        self.chatMessageRepository = chatMessageRepository
    }
    
    func sendMessage(message: ChatMessage, roomName: String) -> Completable {
        return self.chatMessageRepository.sendMessage(
            message: message,
            roomName: roomName
        )
    }
    
    func observeMessage(roomID: String) -> Observable<ChatMessage> {
        return self.chatMessageRepository.observeChatRoomMessages(roomID: roomID)
    }
}
