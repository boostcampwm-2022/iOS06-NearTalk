//
//  MessagingUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/24.
//

import Foundation

import RxSwift

protocol MessagingUseCase {
    func sendMessage(message: ChatMessage, roomID: String, roomName: String, chatMemberIDList: [String]) -> Completable
}

final class DefalultMessagingUseCase: MessagingUseCase {
    private let chatMessageRepository: ChatMessageRepository
    
    init(chatMessageRepository: ChatMessageRepository) {
        self.chatMessageRepository = chatMessageRepository
    }
    
    func sendMessage(message: ChatMessage, roomID: String, roomName: String, chatMemberIDList: [String]) -> Completable {
        return self.chatMessageRepository.sendMessage(
            message: message,
            roomID: roomID,
            roomName: roomName,
            chatMemberIDList: chatMemberIDList
        )
    }
}
