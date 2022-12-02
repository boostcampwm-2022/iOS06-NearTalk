//
//  FetchChatRoomInfoUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/29.
//

import Foundation
import RxSwift

protocol FetchChatRoomInfoUseCase {
    func fetchChatRoomInfo(chatRoomID: String) -> Single<ChatRoom>
    func observrChatRoomInfo(chatRoomID: String) -> Observable<ChatRoom>
}

final class DefaultFetchChatRoomInfoUseCase: FetchChatRoomInfoUseCase {
    
    // MARK: - Propotry
    
    private let chatRoomListRepository: ChatRoomListRepository
    
    // MARK: - LifeCycle
    
    init(chatRoomListRepository: ChatRoomListRepository) {
        self.chatRoomListRepository = chatRoomListRepository
    }
    
    func fetchChatRoomInfo(chatRoomID: String) -> Single<ChatRoom> {
        return chatRoomListRepository.fetchChatRoomInfo(chatRoomID)
    }
    
    func observrChatRoomInfo(chatRoomID: String) -> Observable<ChatRoom> {
        return chatRoomListRepository.observeChatRoomInfo(chatRoomID)
    }
    
    func updateUserChatRoomTicket() {
    
    }
    
}
