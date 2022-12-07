//
//  UserDefaultUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/29.
//

import Foundation

protocol UserDefaultUseCase {
    func fetchUserUUID() -> String?
}

final class DefaultUserDefaultUseCase: UserDefaultUseCase {
    private let userDefaultsRepository: UserDefaultsRepository
    
    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }
    
    func fetchUserUUID() -> String? {
        return self.userDefaultsRepository.fetchUserProfile()?.uuid
    }
    
}
