//
//  ChatRoom.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/16.
//

import Foundation

struct ChatRoom: BaseEntity {
    var uuid: String?
    var userList: [String]?
    var roomImagePath: String?
    var roomType: String?
    var roomName: String?
    var roomDescription: String?
    var location: NCLocation?
    var latitude: Double?
    var longitude: Double?
    var accessibleRadius: Double?
    var recentMessageID: String?
    var recentMessageText: String?
    var recentMessageDate: Date?
    var maxNumberOfParticipants: Int?
    var messageCount: Int?
    var createdAt: Date?
    
    init(
        uuid: String? = nil,
        userList: [String]? = [],
        roomImagePath: String? = nil,
        roomType: String? = nil,
        roomName: String? = nil,
        roomDescription: String? = nil,
        location: NCLocation? = nil,
        latitude: Double?,
        longitude: Double?,
        accessibleRadius: Double? = nil,
        recentMessageID: String? = nil,
        recentMessageText: String? = nil,
        recentMessageDate: Date? = nil,
        maxNumberOfParticipants: Int? = nil,
        messageCount: Int? = nil,
        createdAt: Date? = Date()
    ) {
        self.uuid = uuid
        self.userList = userList
        self.roomImagePath = roomImagePath
        self.roomType = roomType
        self.roomName = roomName
        self.roomDescription = roomDescription
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.accessibleRadius = accessibleRadius
        self.recentMessageID = recentMessageID
        self.recentMessageText = recentMessageText
        self.recentMessageDate = recentMessageDate
        self.maxNumberOfParticipants = maxNumberOfParticipants
        self.messageCount = messageCount
        self.createdAt = createdAt
    }
}
