//
//  ChatMessageRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/23.
//

import Foundation
import RxSwift

protocol ChatMessageRepository {
    func sendMessage(message: ChatMessage, roomName: String) -> Completable
    func fetchSingleMessage(messageID: String, roomID: String) -> Single<ChatMessage>
    func fetchMessage(page: Int, skip: Int, count: Int, roomID: String) -> Single<[ChatMessage]>
    func observeChatRoomMessages(roomID: String) -> Observable<ChatMessage>
    
    func updateChatRoom(_ chatRoom: ChatRoom) -> Single<ChatRoom>
}
