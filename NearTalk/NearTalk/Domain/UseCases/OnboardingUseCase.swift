//
//  OnboardingUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/16.
//

import Foundation

protocol OnboardingValidateUseCase {
    func validateNickName(_ value: String) -> Bool
    func validateMessage(_ value: String) -> Bool
}

protocol OnboardingSaveProfileUseCase {
    func saveProfile(_ nickName: String, _ message: String, image: Data?) -> Bool
}

final class DefaultOnboardingValidateUseCase: OnboardingValidateUseCase {
    /// 5자 이상, 20자 이하, 알파벳 소문자, 숫자, 특수문자(_-) 만 가능
    private let nickNameRegex: String = #"^[\da-z_-]{5,20}$"#
    func validateNickName(_ value: String) -> Bool {
        return value.matchRegex(self.nickNameRegex)
    }
    func validateMessage(_ value: String) -> Bool {
        return value.count <= 50
    }
}

final class DefaultOnboardingSaveProfileUseCase: OnboardingSaveProfileUseCase {
    private let profileRepository: any UserProfileRepository
    private let uuidRepository: any UserUUIDRepository
    private let imageRepository: any ImageRepository

    init(profileRepository: any UserProfileRepository,
         uuidRepository: any UserUUIDRepository,
         imageRepository: any ImageRepository) {
        self.profileRepository = profileRepository
        self.uuidRepository = uuidRepository
        self.imageRepository = imageRepository
    }
    
    func saveProfile(_ nickName: String, _ message: String, image: Data?) -> Bool {
        let path: String?
        if let image = image {
            path = self.imageRepository.save(image: image)
        } else {
            path = nil
        }
        return self.profileRepository.save(UserProfile(
            userID: self.uuidRepository.fetch(),
            username: nickName,
            statusMessage: message,
            profileImagePath: path,
            friends: nil))
    }
}

final class TestOnboardingValidateUseCase: OnboardingValidateUseCase {
    func validateNickName(_ value: String) -> Bool {
        return !value.isEmpty
    }
    func validateMessage(_ value: String) -> Bool {
        return !value.isEmpty
    }
}
