//
//  CreateProfileUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import Foundation
import RxSwift

protocol CreateProfileUseCase {
    func execute(profile: UserProfile) -> Completable
}

final class DefaultCreateProfileUseCase: CreateProfileUseCase {
    private let profileRepository: any ProfileRepository
    private let userDefaultsRepository: any UserDefaultsRepository

    init(
        profileRepository: ProfileRepository,
        userDefaultsRepository: any UserDefaultsRepository
    ) {
        self.profileRepository = profileRepository
        self.userDefaultsRepository = userDefaultsRepository
    }

    func execute(profile: UserProfile) -> Completable {
        return self.profileRepository.createMyProfile(profile)
            .do(onSuccess: { [weak self] profile in
                self?.userDefaultsRepository.saveUserProfile(profile)
            })
            .asCompletable()
    }
}
