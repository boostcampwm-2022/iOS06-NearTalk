//
//  UserChatRoomTicket.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/23.
//

import Foundation

/// 유저가 특정 채팅방에서 마지막으로 읽은 메시지
struct UserChatRoomTicket: BaseEntity {
    var uuid: String?
    var userID: String?
    var roomID: String?
    var lastReadMessageID: String?
    
    /// Date().timeIntervalSince1970 값
    var createdAtTimeStamp: Double?
    
    /// 읽었을 당시 채팅방의 총 메시지 갯수
    var lastRoomMessageCount: Int?
}
