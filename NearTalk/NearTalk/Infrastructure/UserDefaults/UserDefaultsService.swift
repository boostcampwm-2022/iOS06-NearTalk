//
//  UserDefaultsService.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/28.
//

import Foundation

protocol UserDefaultService {
    func saveUserProfile(_ profile: UserProfile)
    func fetchUserProfile() -> UserProfile?
    func removeUserProfile()
}

final class DefaultUserDefaultsService: UserDefaultService {
    func saveUserProfile(_ profile: UserProfile) {
        if let data: Data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: UserDefaultsKey.userProfile.rawValue)
        }
    }
    
    func fetchUserProfile() -> UserProfile? {
        if let data: Data = UserDefaults.standard.value(forKey: UserDefaultsKey.userProfile.rawValue) as? Data,
           let userProfile: UserProfile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return userProfile
        }
        return nil
    }
    
    func removeUserProfile() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.userProfile.rawValue)
    }
}

enum UserDefaultsKey: String {
    case userProfile
    case currentUserLatitude
    case currentUserLongitude
    case profileImagePath
    
    var string: String {
        return self.rawValue
    }
}
