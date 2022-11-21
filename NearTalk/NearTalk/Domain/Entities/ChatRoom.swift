//
//  ChatRoom.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/16.
//

import Foundation

struct ChatRoom: Codable {
    var roomID: String?
    var userList: [String]?
    var roomImagePath: String?
    var roomType: String?
    var roomName: String?
    var roomDescription: String?
    var location: NCLocation?
    var accessibleRadius: Double?
    var recentMessageID: String?
    var maxNumberOfParticipants: Int?
}
