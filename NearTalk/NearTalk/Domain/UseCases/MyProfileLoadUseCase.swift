//
//  MyProfileLoadUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation

protocol MyProfileLoadUseCase {
    func loadProfile() -> UserProfile
}

final class DefaultMyProfileLoadUseCase: MyProfileLoadUseCase {
    private let profileRepository: any UserProfileRepository
    private let uuidRepository: any UserUUIDRepository
    init(profileRepository: any UserProfileRepository,
         uuidRepository: any UserUUIDRepository) {
        self.profileRepository = profileRepository
        self.uuidRepository = uuidRepository
    }
    
    func loadProfile() -> UserProfile {
        let uuid = self.uuidRepository.loadUUID()
        return self.profileRepository.load(uuid: uuid)
    }
}
