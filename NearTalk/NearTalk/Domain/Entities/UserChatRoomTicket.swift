//
//  UserChatRoomTicket.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/23.
//

import Foundation

struct UserChatRoomTicket: BaseEntity {
    var uuid: String?
    var userID: String?
    var roomID: String?
    var lastReadMessageID: String?
    var lastRoomMessageCount: Int?
}
