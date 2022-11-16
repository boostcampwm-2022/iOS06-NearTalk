//
//  UserProfile.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/16.
//

import Foundation

struct UserProfile {
    let nickName: String
    let message: String
    let image: Data?
}

protocol UserProfileRepository {
    func save(_ profile: UserProfile)
}

final class DefaultUserProfileRepository: UserProfileRepository {
    func save(_ profile: UserProfile) {
        #if DEBUG
        print(profile)
        #endif
    }
}
