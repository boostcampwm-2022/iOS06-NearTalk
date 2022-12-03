//
//  DropOutUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift

protocol DropoutUseCase {
    func reauthenticate(token: String) -> Completable
    func dropout() -> Completable
}

final class DefaultDropOutUseCase: DropoutUseCase {
    private let profileRepository: any ProfileRepository
    private let userDefaultsRepository: any UserDefaultsRepository
    private let authRepository: any AuthRepository
    
    init(profileRepository: any ProfileRepository,
         userDefaultsRepository: any UserDefaultsRepository,
         authRepository: any AuthRepository) {
        self.profileRepository = profileRepository
        self.userDefaultsRepository = userDefaultsRepository
        self.authRepository = authRepository
    }
    
    func reauthenticate(token: String) -> Completable {
        self.authRepository.reauthenticate(token: token)
    }
    
    func dropout() -> Completable {
        userDefaultsRepository.removeUserProfile()
        return self.deleteProfile()
            .andThen(self.authRepository.dropout())
    }
    
    private func deleteProfile() -> Completable {
        return self.profileRepository.deleteMyProfile()
    }
}
