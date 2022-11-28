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
    private let fcmService: FCMService
    
    init(
        databaseService: RealTimeDatabaseService,
        fcmService: FCMService
    ) {
        self.databaseService = databaseService
        self.fcmService = fcmService
    }
    
    func sendMessage(message: ChatMessage, roomName: String) -> Completable {
        self.databaseService.sendMessage(message)
            .andThen(self.fcmService.sendMessage(message, roomName))
    }
    
    func fetchSingleMessage(messageID: String, roomID: String) -> Single<ChatMessage> {
        self.databaseService.fetchSingleMessage(messageID: messageID, roomID: roomID)
    }
    
    func fetchMessage(page: Int, skip: Int, count: Int, roomID: String) -> Single<[ChatMessage]> {
        self.databaseService.fetchMessages(page: page, skip: skip, pageCount: count, roomID: roomID)
    }
    
    func observeChatRoomMessages(roomID: String) -> Observable<ChatMessage> {
        self.databaseService.observeNewMessage(roomID)
    }
}
