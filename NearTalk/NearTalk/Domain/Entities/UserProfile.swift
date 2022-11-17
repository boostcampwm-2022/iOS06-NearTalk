//
//  UserProfile.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/16.
//

import Foundation

struct UserProfile: Codable {
    /// 유저 UUID
    var userID: String?
    var username: String?
    var statusMessage: String?
    var profileImagePath: String?

    /// 친구 UUID 목록
    var friends: [String]?
}
