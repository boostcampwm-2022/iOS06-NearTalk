//
//  FCMNotificationDTO.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/25.
//

import Foundation

struct FCMNotificationDTO: Codable {
    var to: String?
    var notification: NotiTitleAndBody?
    var data: NotiData?
}

struct NotiTitleAndBody: Codable {
    var title: String?
    var body: String?
}

struct NotiData: Codable {
    
}
