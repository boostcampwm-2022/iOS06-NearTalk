//
//  DefaultUserDefaultsRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/28.
//

import Foundation

final class DefaultUserDefaultsRepository: UserDefaultsRepository {
    private let userDefaultsService: UserDefaultService
    
    init(userDefaultsService: UserDefaultService) {
        self.userDefaultsService = userDefaultsService
    }
    
    func saveUserProfile(_ profile: UserProfile) {
        userDefaultsService.saveUserProfile(profile)
    }
    
    func fetchUserProfile() -> UserProfile? {
        return userDefaultsService.fetchUserProfile()
    }
    
    func removeUserProfile() {
        userDefaultsService.removeUserProfile()
    }
}
