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
    private let userDefaultsRepository: any UserDefaultsRepository
    
    init(profileRepository: any ProfileRepository,
         userDefaultsRepository: any UserDefaultsRepository) {
        self.profileRepository = profileRepository
        self.userDefaultsRepository = userDefaultsRepository
    }
    
    func execute() -> Completable {
        userDefaultsRepository.removeUserProfile()
        return self.deleteProfile()
    }
    
    private func deleteProfile() -> Completable {
        return self.profileRepository.deleteMyProfile()
    }
}
