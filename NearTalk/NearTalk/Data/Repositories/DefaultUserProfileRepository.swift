//
//  DefaultUserProfileRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation

final class DefaultUserProfileRepository: UserProfileRepository {
    func save(_ profile: UserProfile) {
        #if DEBUG
        print(profile)
        #endif
    }
    
    func load(uuid: String) -> UserProfile {
        return UserProfile(nickName: "JK", message: "code squard ceo", image: nil)
    }
}
