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
//    func fetchUID() -> Single<String>
}

final class DefaultCreateProfileUseCase: CreateProfileUseCase {
    private let profileRepository: any ProfileRepository
    private let authRepository: any AuthRepository

    init(profileRepository: ProfileRepository, authRepository: any AuthRepository) {
        self.profileRepository = profileRepository
        self.authRepository = authRepository
    }
    
//    func fetchUID() -> Single<String> {
//        return self.authRepository.fetchCurrentUserUID()
//    }
    
    func execute(profile: UserProfile) -> Completable {
        return self.profileRepository.createMyProfile(profile)
            .asCompletable()
    }
}
