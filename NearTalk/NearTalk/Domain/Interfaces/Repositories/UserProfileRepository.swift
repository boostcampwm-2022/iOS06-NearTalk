//
//  UserProfileRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation

protocol UserProfileRepository {
    @discardableResult
    func save(_ profile: UserProfile) -> Bool
    func fetch(uuid: String) -> UserProfile
    @discardableResult
    func create(userID: String, username: String, statusMessage: String, profileImage: Data?) -> Bool
}
