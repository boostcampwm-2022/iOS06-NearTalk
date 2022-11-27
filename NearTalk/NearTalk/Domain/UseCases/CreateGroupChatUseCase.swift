//
//  CreateGroupChatUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/17.
//

import Foundation

import RxSwift

protocol CreateGroupChatUseCaseable {
    func createGroupChat(chatRoom: ChatRoom) -> Completable
}

final class CreateGroupChatUseCase {
    // MARK: - Proporties
    
    private let chatRoomListRepository: ChatRoomListRepository
    
    // MARK: - Life Cycle
    
    init(chatRoomListRepository: ChatRoomListRepository) {
        self.chatRoomListRepository = chatRoomListRepository
    }
}

extension CreateGroupChatUseCase: CreateGroupChatUseCaseable {
    func createGroupChat(chatRoom: ChatRoom) -> Completable {
        return self.chatRoomListRepository.createChatRoom(chatRoom)
    }
}
