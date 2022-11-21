//
//  CreateProfileUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import Foundation
import RxSwift

protocol CreateProfileUseCase {
    init(profileRepository: any ProfileRepository)
    func execute(profile: UserProfile) -> Completable
}

final class DefaultCreateProfileUseCase: CreateProfileUseCase {
    private let profileRepository: any ProfileRepository

    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }
    
    func execute(profile: UserProfile) -> Completable {
        return self.profileRepository.createMyProfile(profile)
            .asCompletable()
    }
}
