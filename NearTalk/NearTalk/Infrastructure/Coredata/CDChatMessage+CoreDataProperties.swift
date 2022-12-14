//
//  CDChatMessage+CoreDataProperties.swift
//  
//
//  Created by 고병학 on 2022/12/10.
//
//

import CoreData
import Foundation

extension CDChatMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDChatMessage> {
        return NSFetchRequest<CDChatMessage>(entityName: "CDChatMessage")
    }

    @NSManaged public var chatRoomID: String?
    @NSManaged public var createdAtTimeStamp: Double
    @NSManaged public var mediaPath: String?
    @NSManaged public var mediaType: String?
    @NSManaged public var messageType: String?
    @NSManaged public var senderID: String?
    @NSManaged public var text: String?
    @NSManaged public var id: String?

    func getChatMessage() -> ChatMessage {
        return ChatMessage(
            uuid: self.id,
            chatRoomID: self.chatRoomID,
            senderID: self.senderID,
            text: self.text,
            messageType: self.messageType,
            mediaPath: self.mediaPath,
            mediaType: self.mediaType,
            createdAtTimeStamp: self.createdAtTimeStamp
        )
    }
}
