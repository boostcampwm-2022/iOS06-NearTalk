//
//  UpdateProfileUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift

protocol UpdateProfileUseCase {
    init(repository: any ProfileRepository, userDefaultsRepository: any UserDefaultsRepository)
    func execute(profile: UserProfile) -> Completable
    func updateFriendsProfile(profile: UserProfile) -> Completable
}

final class DefaultUpdateProfileUseCase: UpdateProfileUseCase {
    private let repository: any ProfileRepository
    private let userDefaultsRepository: any UserDefaultsRepository

    init(repository: ProfileRepository, userDefaultsRepository: any UserDefaultsRepository) {
        self.repository = repository
        self.userDefaultsRepository = userDefaultsRepository
    }
    
    func execute(profile: UserProfile) -> Completable {
        return self.repository.updateMyProfile(profile)
            .do(onSuccess: { [weak self] profile in
                self?.userDefaultsRepository.saveUserProfile(profile)
            })
            .asCompletable()
    }
    
    func updateFriendsProfile(profile: UserProfile) -> Completable {
        return self.repository.updateFriendProfile(profile)
    }
}
