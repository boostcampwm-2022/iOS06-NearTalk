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
    private let repository: any UserProfileRepository
    
    init(repository: any UserProfileRepository) {
        self.repository = repository
    }
    
    func saveProfile(_ nickName: String, _ message: String, image: Data?) -> Bool {
        self.repository.save(UserProfile(nickName: nickName, message: message, image: image))
        return true
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
