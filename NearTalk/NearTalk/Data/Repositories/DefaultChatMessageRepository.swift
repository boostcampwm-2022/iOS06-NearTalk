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
    private let profileRepository: any ProfileRepository
    private let fcmService: FCMService
    
    init(
        databaseService: RealTimeDatabaseService,
        profileRepository: any ProfileRepository,
        fcmService: FCMService
    ) {
        self.databaseService = databaseService
        self.profileRepository = profileRepository
        self.fcmService = fcmService
    }
    
    #warning("메시지 전송 결과에 대한 예외처리 필요")
    func sendMessage(message: ChatMessage, roomID: String, roomName: String, chatMemberIDList: [String]) -> Completable {
        self.databaseService.fetchChatRoomInfo(roomID)
            .do(onSuccess: { [weak self] _ in
                _ = self?.databaseService.sendMessage(message)
            })
            .flatMapCompletable { chatRoom in
                var newChatRoom: ChatRoom = chatRoom
                newChatRoom.recentMessageID = message.chatRoomID
                newChatRoom.recentMessageDate = message.createdDate
                newChatRoom.recentMessageText = message.text
                return self.databaseService.updateChatRoom(newChatRoom).asCompletable()
            }
            .andThen(self.databaseService.increaseChatRoomMessageCount(roomID))
            .andThen(self.sendPushNotification(message, roomName, chatMemberIDList))
    }
    
    private func sendPushNotification(_ message: ChatMessage, _ roomName: String, _ chatMemberIDList: [String]) -> Completable {
        self.profileRepository.fetchProfileByUUIDList(chatMemberIDList)
            .flatMapCompletable { (profileList: [UserProfile]) in
                self.fcmService.sendMessage(message, roomName, profileList.compactMap({ $0.fcmToken }))
            }
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
    
    func updateChatRoom(_ chatRoom: ChatRoom) -> Single<ChatRoom> {
        self.databaseService.updateChatRoom(chatRoom)
    }
}

enum DefaultChatMessageRepositoryError: Error {
    case fetchRoomInfoError
}
