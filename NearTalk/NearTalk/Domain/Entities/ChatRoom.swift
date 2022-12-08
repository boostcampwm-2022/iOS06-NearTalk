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
    var recentMessageDateTimeStamp: Double?
    var maxNumberOfParticipants: Int?
    var messageCount: Int?
    
    /// Date().timeIntervalSince1970 값
    var createdAtTimeStamp: Double?
    
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
        recentMessageDateTimeStamp: Double? = nil,
        maxNumberOfParticipants: Int? = nil,
        messageCount: Int? = nil,
        createdAtTimeStamp: Double? = Date().timeIntervalSince1970
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
        self.recentMessageDateTimeStamp = recentMessageDateTimeStamp
        self.maxNumberOfParticipants = maxNumberOfParticipants
        self.messageCount = messageCount
        self.createdAtTimeStamp = createdAtTimeStamp
    }
}
