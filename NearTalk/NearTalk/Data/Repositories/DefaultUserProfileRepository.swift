//
//  DefaultUserProfileRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation

final class DefaultUserProfileRepository: UserProfileRepository {
    func save(_ profile: UserProfile) -> Bool {
        return true
    }
    
    func create(userID: String, username: String, statusMessage: String, profileImage: Data?) -> Bool {
        return true
    }
    
    func fetch(uuid: String) -> UserProfile {
        return UserProfile(userID: uuid, username: "sample", statusMessage: "sample message", profileImagePath: nil, friends: nil)
    }
}
