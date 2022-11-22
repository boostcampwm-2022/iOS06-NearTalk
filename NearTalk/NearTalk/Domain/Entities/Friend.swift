//
//  Friends.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/21.
//

import Foundation

struct Friend: Codable, Hashable {
    /// 유저 UUID
    var userID: String?
    var username: String?
    var statusMessage: String?
    var profileImagePath: String?
}
