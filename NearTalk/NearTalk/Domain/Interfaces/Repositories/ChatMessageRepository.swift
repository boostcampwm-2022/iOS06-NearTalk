//
//  ChatMessageRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/23.
//

import Foundation
import RxSwift

protocol ChatMessageRepository {
    func sendMessage(_ message: ChatMessage) -> Completable
    func fetchMessage(page: Int, skip: Int, count: Int, roomID: String) -> Single<[ChatMessage]>
    func observeChatRoomMessages(roomID: String) -> Observable<ChatMessage>
}
