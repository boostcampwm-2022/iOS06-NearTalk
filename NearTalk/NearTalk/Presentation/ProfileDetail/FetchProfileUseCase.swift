//
//  FetchProfileUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/21.
//

import Foundation

import RxSwift

protocol FetchProfileUseCase {
    func fetchUserInfo(with userID: String) -> Single<UserProfile>
    func updateUserProfile(userProfile: UserProfile)
}

final class DefaultFetchProfileUseCase: FetchProfileUseCase {
    private let disposebag: DisposeBag = DisposeBag()
    private let userProfileRepository: ProfileRepository
    
    init(profileRepository: ProfileRepository) {
        self.userProfileRepository = profileRepository
    }
    
    func fetchUserInfo(with userID: String) -> Single<UserProfile> {
        return self.userProfileRepository.fetchProfileByUUID(userID)
    }
    
    func updateUserProfile(userProfile: UserProfile) {
        _ = self.userProfileRepository.updateMyProfile(userProfile)
    }
}
