//
//  CreateGroupChatUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/17.
//

import Foundation

import RxSwift

protocol CreateGroupChatUseCase {
    func createGroupChat(chatRoom: ChatRoom) -> Completable
    func addChatRoom(chatRoomUUID: String) -> Completable
}

final class DefaultCreateGroupChatUseCase {
    // MARK: - Proporties
    
    private let chatRoomListRepository: ChatRoomListRepository
    private let profileRepository: ProfileRepository
    
    // MARK: - Life Cycle
    init(chatRoomListRepository: ChatRoomListRepository, profileRepository: ProfileRepository) {
        self.chatRoomListRepository = chatRoomListRepository
        self.profileRepository = profileRepository
    }
}

extension DefaultCreateGroupChatUseCase: CreateGroupChatUseCase {
    func createGroupChat(chatRoom: ChatRoom) -> Completable {
        return self.chatRoomListRepository.createChatRoom(chatRoom)
    }
    
    func addChatRoom(chatRoomUUID: String) -> Completable {
        return profileRepository.addChatRoom(chatRoomUUID)
    }
}
