//
//  FCMNotificationDTO.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/25.
//

import Foundation

struct FCMNotificationDTO: Codable {
    var notification: NotiTitleAndBody?
    var data: NotiData?
    var registrationIds: [String]?
    
    enum CodingKeys: String, CodingKey {
        case notification
        case data
        case registrationIds = "registration_ids"
    }
}

struct NotiTitleAndBody: Codable {
    var title: String?
    var body: String?
}

struct NotiData: Codable {
    
}
