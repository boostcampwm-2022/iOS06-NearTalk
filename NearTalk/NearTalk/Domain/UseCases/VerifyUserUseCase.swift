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
    
    init(authRepository: AuthRepository, profileRepository: ProfileRepository) {
        self.authRepository = authRepository
        self.profileRepository = profileRepository
    }
    
    func verifyUser() -> Completable {
        self.authRepository.verify()
    }
    
    func verifyProfile() -> Completable {
        self.profileRepository.fetchMyProfile().asCompletable()
    }
}
