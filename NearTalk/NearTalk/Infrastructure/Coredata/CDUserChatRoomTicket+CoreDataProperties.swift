//
//  CDUserChatRoomTicket+CoreDataProperties.swift
//  
//
//  Created by 고병학 on 2022/12/06.
//
//

import CoreData
import Foundation

extension CDUserChatRoomTicket {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUserChatRoomTicket> {
        return NSFetchRequest<CDUserChatRoomTicket>(entityName: "CDUserChatRoomTicket")
    }

    @NSManaged public var lastReadMessageID: String?
    @NSManaged public var lastRoomMessageCount: Int64
    @NSManaged public var roomID: String?
    @NSManaged public var userID: String?
    @NSManaged public var uuid: String?

}
