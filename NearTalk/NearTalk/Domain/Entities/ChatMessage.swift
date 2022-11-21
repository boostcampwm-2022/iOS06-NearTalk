//
//  ChatMessage.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/16.
//

import Foundation

struct ChatMessage: Codable {
    var messageID: String?
    var chatRoomID: String?
    var senderID: String?
    var text: String?
    var messageType: String?
    var mediaPath: String?
    var mediaType: String?
    var createdDate: Date?
}

enum MessageType: String {
    case text
    case media
}

enum MediaType: String {
    case photo
    case video
}
