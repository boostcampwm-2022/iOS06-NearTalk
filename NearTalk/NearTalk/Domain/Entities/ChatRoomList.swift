//
//  ChatRoomList.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation

struct GroupChatRoomListData: Hashable {
    var uuid: String?
    var userList: [String]?
    var roomImagePath: String?
    var roomName: String?
    var accessibleRadius: Double?
    var recentMessageID: String?
    var messageCount: Int?
    
    init(data: ChatRoom) {
        self.uuid = data.uuid
        self.userList = data.userList
        self.roomImagePath = data.roomImagePath
        self.roomName = data.roomName
        self.accessibleRadius = data.accessibleRadius
        self.recentMessageID = data.recentMessageID
        self.messageCount = data.messageCount
    }
    
}

struct DMChatRoomListData: Hashable {
    var uuid: String?
    var roomImagePath: String?
    var roomName: String?
    var recentMessageID: String?
    var messageCount: Int?
    
    init(data: ChatRoom) {
        self.uuid = data.uuid
        self.roomImagePath = data.roomImagePath
        self.roomName = data.roomName
        self.recentMessageID = data.recentMessageID
        self.messageCount = data.messageCount
    }
}
