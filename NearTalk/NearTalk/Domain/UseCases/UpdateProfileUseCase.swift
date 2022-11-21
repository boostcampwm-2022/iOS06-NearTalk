//
//  UpdateProfileUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift

protocol UpdateProfileUseCase {
    init(repository: any ProfileRepository)
    func execute(profile: UserProfile) -> Completable
}

final class DefaultUpdateProfileUseCase: UpdateProfileUseCase {
    private let repository: any ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }
    
    func execute(profile: UserProfile) -> Completable {
        return self.repository.updateMyProfile(profile).asCompletable()
    }
}
