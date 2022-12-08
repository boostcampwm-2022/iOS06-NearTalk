//
//  CDChatMessage+CoreDataProperties.swift
//  
//
//  Created by 고병학 on 2022/12/06.
//
//

import CoreData
import Foundation

extension CDChatMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDChatMessage> {
        return NSFetchRequest<CDChatMessage>(entityName: "CDChatMessage")
    }

    @NSManaged public var chatRoomID: String?
    @NSManaged public var createdAtTimeStamp: NSNumber?
    @NSManaged public var mediaPath: String?
    @NSManaged public var mediaType: String?
    @NSManaged public var messageType: String?
    @NSManaged public var senderID: String?
    @NSManaged public var text: String?
    @NSManaged public var uuid: String?

}
