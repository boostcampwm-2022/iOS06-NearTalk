//
//  DefaultChatMessageRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/23.
//

import Foundation
import RxSwift

final class DefaultChatMessageRepository: ChatMessageRepository {
    private let databaseService: RealTimeDatabaseService
    
    init(databaseService: RealTimeDatabaseService) {
        self.databaseService = databaseService
    }
    
    func sendMessage(_ message: ChatMessage) -> Completable {
        self.databaseService.sendMessage(message)
    }
    
    func fetchMessage(page: Int, skip: Int, count: Int, roomID: String) -> Single<[ChatMessage]> {
        self.databaseService.fetchMessages(page: page, skip: skip, pageCount: count, roomID: roomID)
    }
    
    func observeChatRoomMessages(roomID: String) -> Observable<ChatMessage> {
        self.databaseService.observeNewMessage(roomID)
    }
}
