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
    var recentMessageText: String?
    var recentMessageDate: Date?
    var messageCount: Int?
    var location: NCLocation?
    var latitude: Double?
    var longitude: Double?
    
    init(data: ChatRoom) {
        self.uuid = data.uuid
        self.userList = data.userList
        self.roomImagePath = data.roomImagePath
        self.roomName = data.roomName
        self.accessibleRadius = data.accessibleRadius
        self.messageCount = data.messageCount
        self.recentMessageText = data.recentMessageText
        self.recentMessageDate = data.recentMessageDate
        self.location = data.location
        self.latitude = data.latitude
        self.longitude = data.longitude
    }
    
}

struct DMChatRoomListData: Hashable {
    var uuid: String?
    var roomImagePath: String?
    var roomName: String?
    var recentMessageID: String?
    var recentMessageText: String?
    var recentMessageDate: Date?
    var messageCount: Int?
    
    init(data: ChatRoom) {
        self.uuid = data.uuid
        self.roomImagePath = data.roomImagePath
        self.roomName = data.roomName
        self.recentMessageID = data.recentMessageID
        self.messageCount = data.messageCount
        self.recentMessageText = data.recentMessageText
        self.recentMessageDate = data.recentMessageDate
    }
}
