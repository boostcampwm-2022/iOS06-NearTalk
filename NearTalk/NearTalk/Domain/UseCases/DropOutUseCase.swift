//
//  DropOutUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift

protocol DropoutUseCase {
    func execute() -> Completable
    init(authRepository: AuthRepository, profileRepository: ProfileRepository)
}

final class DefaultDropOutUseCase: DropoutUseCase {
    private let authRepository: any AuthRepository
    private let profileRepository: any ProfileRepository
    
    init(authRepository: AuthRepository, profileRepository: ProfileRepository) {
        self.authRepository = authRepository
        self.profileRepository = profileRepository
    }
    
    func execute() -> Completable {
        return self.deleteProfile()//.andThen(self.deleteAccount())
    }
    
    private func deleteProfile() -> Completable {
        return self.profileRepository.deleteMyProfile()
    }
    
    private func deleteAccount() -> Completable {
        return self.authRepository.dropout()
    }
}
