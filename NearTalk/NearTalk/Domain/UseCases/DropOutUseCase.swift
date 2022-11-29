//
//  DropOutUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift

protocol DropoutUseCase {
    func execute() -> Completable
}

final class DefaultDropOutUseCase: DropoutUseCase {
    private let profileRepository: any ProfileRepository
    private let authRepository: any AuthRepository
    private let userDefaultsRepository: any UserDefaultsRepository
    
    init(profileRepository: any ProfileRepository,
         authRepository: any AuthRepository,
         userDefaultsRepository: any UserDefaultsRepository) {
        self.profileRepository = profileRepository
        self.authRepository = authRepository
        self.userDefaultsRepository = userDefaultsRepository
    }
    
    func execute() -> Completable {
        userDefaultsRepository.removeUserProfile()
        return self.deleteProfile().andThen(self.deleteAccount())
    }
    
    private func deleteProfile() -> Completable {
        return self.profileRepository.deleteMyProfile()
    }
    
    private func deleteAccount() -> Completable {
        return self.authRepository.dropout()
    }
}
