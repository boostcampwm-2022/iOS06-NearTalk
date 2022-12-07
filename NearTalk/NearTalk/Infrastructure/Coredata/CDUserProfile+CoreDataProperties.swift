//
//  CDUserProfile+CoreDataProperties.swift
//  
//
//  Created by 고병학 on 2022/12/06.
//
//

import CoreData
import Foundation

extension CDUserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUserProfile> {
        return NSFetchRequest<CDUserProfile>(entityName: "CDUserProfile")
    }

    @NSManaged public var chatRooms: [String]?
    @NSManaged public var email: String?
    @NSManaged public var fcmToken: String?
    @NSManaged public var friends: [String]?
    @NSManaged public var profileImagePath: String?
    @NSManaged public var statusMessage: String?
    @NSManaged public var username: String?
    @NSManaged public var uuid: String?

}
