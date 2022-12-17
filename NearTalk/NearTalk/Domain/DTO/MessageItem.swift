//
//  MessageItem.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/12/07.
//

import Foundation

struct MessageItem: Hashable {
    var id: String
    var senderID: String?
    var userName: String?
    var message: String?
    var type: MyMessageType
    var imagePath: String?
    var createdAt: Date
    var createdAtTimeStamp: Double?
    
    init(
        chatMessage: ChatMessage,
        myID: String,
        userProfile: UserProfile?,
        createdAtTimeStamp: Double? = nil
    ) {
        self.id = chatMessage.uuid ?? UUID().uuidString
        self.senderID = chatMessage.senderID
        self.userName = userProfile?.username
        self.message = chatMessage.text
        self.type = chatMessage.senderID == myID ? MyMessageType.send : MyMessageType.receive
        self.imagePath = userProfile?.profileImagePath
        self.createdAt = Date(timeIntervalSince1970: chatMessage.createdAtTimeStamp ?? Date().timeIntervalSince1970)
    }
}

enum MyMessageType: String {
    case send
    case receive
}
