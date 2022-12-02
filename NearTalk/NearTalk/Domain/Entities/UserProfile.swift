//
//  UserProfile.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/16.
//

import Foundation

struct UserProfile: BaseEntity {
    /// 유저 UUID
    var uuid: String?
    var username: String?
    var email: String?
    var statusMessage: String?
    var profileImagePath: String?

    /// 친구 UUID 목록
    var friends: [String]?
    
    /// 입장한 채팅방 UUID 목록
    var chatRooms: [String]?
    
    /// FCM 토큰
    var fcmToken: String?
    
    init(uuid: String? = nil, username: String? = nil, email: String? = nil, statusMessage: String? = nil, profileImagePath: String? = nil, friends: [String]? = [], chatRooms: [String]? = [], fcmToken: String? = nil) {
        self.uuid = uuid
        self.username = username
        self.email = email
        self.statusMessage = statusMessage
        self.profileImagePath = profileImagePath
        self.friends = friends
        self.chatRooms = chatRooms
        self.fcmToken = fcmToken
    }
}
