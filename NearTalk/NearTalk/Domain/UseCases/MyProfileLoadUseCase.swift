//
//  MyProfileLoadUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation

protocol MyProfileLoadUseCase {
    func fetchProfile() -> UserProfile
    func fetchImage(path: String) -> Data?
}

final class DefaultMyProfileLoadUseCase: MyProfileLoadUseCase {
    private let profileRepository: any UserProfileRepository
    private let uuidRepository: any UserUUIDRepository
    private let imageRepository: any ImageRepository
    
    init(profileRepository: any UserProfileRepository,
         uuidRepository: any UserUUIDRepository,
         imageRepository: ImageRepository) {
        self.profileRepository = profileRepository
        self.uuidRepository = uuidRepository
        self.imageRepository = imageRepository
    }
    
    func fetchImage(path: String) -> Data? {
        self.imageRepository.fetch(path: path)
    }
    
    func fetchProfile() -> UserProfile {
        let uuid = self.uuidRepository.fetch()
        return self.profileRepository.fetch(uuid: uuid)
    }
}
