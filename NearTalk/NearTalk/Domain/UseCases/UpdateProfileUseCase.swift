//
//  UpdateProfileUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift

protocol UpdateProfileUseCase {
    init(repository: any ProfileRepository)
    func execute(profile: UserProfile) -> Single<UserProfile>
}

final class DefaultUpdateProfileUseCase: UpdateProfileUseCase {
    private let repository: any ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }
    
    func execute(profile: UserProfile) -> RxSwift.Single<UserProfile> {
        return self.repository.updateMyProfile(profile)
    }
}
