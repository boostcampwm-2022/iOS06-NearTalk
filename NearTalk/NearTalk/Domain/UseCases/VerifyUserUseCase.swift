//
//  VerifyUserUseCase.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/21.
//

import Foundation
import RxSwift

protocol VerifyUserUseCase {
    func verifyUser() -> Completable
    func verifyProfile() -> Completable
}

final class DefaultVerifyUserUseCase: VerifyUserUseCase {
    private let authRepository: AuthRepository
    private let profileRepository: ProfileRepository
    private let userDefaultsRepository: UserDefaultsRepository
    
    init(
        authRepository: AuthRepository,
        profileRepository: ProfileRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.authRepository = authRepository
        self.profileRepository = profileRepository
        self.userDefaultsRepository = userDefaultsRepository
    }
    
    func verifyUser() -> Completable {
        self.authRepository.verify()
    }
    
    func verifyProfile() -> Completable {
        self.profileRepository.fetchMyProfile()
            .do(onSuccess: { [weak self] profile in
                self?.userDefaultsRepository.saveUserProfile(profile)
            })
            .asCompletable()
    }
}
