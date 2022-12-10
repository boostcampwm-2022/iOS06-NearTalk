//
//  UserDefaultUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/29.
//

import Foundation

protocol UserDefaultUseCase {
    func fetchUserUUID() -> String?
    func fetchUserProfile() -> UserProfile?
    func fetchCurrentLocation()
}

final class DefaultUserDefaultUseCase: UserDefaultUseCase {
    private let userDefaultsRepository: UserDefaultsRepository
    
    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }
    
    func fetchUserUUID() -> String? {
        return self.userDefaultsRepository.fetchUserProfile()?.uuid
    }
    
    func fetchUserProfile() -> UserProfile? {
        return self.userDefaultsRepository.fetchUserProfile()
    }
    
    func fetchCurrentLocation() {
        
    }
}
