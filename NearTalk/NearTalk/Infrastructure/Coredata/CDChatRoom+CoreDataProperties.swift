//
//  CDChatRoom+CoreDataProperties.swift
//  
//
//  Created by 고병학 on 2022/12/06.
//
//

import CoreData
import Foundation

extension CDChatRoom {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDChatRoom> {
        return NSFetchRequest<CDChatRoom>(entityName: "CDChatRoom")
    }

    @NSManaged public var roomImagePath: String?
    @NSManaged public var roomType: String?
    @NSManaged public var userList: [String]?
    @NSManaged public var uuid: String?

}
