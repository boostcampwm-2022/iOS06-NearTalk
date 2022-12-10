//
//  FetchProfileUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/21.
//

import Foundation

import RxSwift

protocol FetchProfileUseCase {
    func fetchUserProfile(with userID: String) -> Single<UserProfile>
    func fetchMyProfile() -> Single<UserProfile>
    func updateUserProfile(userProfile: UserProfile)
    func updateUserProfileCompletable(userProfile: UserProfile) -> Completable
    func fetchUserProfiles(with userIDList: [String]) -> Single<[UserProfile]>
}

final class DefaultFetchProfileUseCase: FetchProfileUseCase {
    private let userProfileRepository: ProfileRepository
    
    init(profileRepository: ProfileRepository) {
        self.userProfileRepository = profileRepository
    }
    
    func fetchMyProfile() -> Single<UserProfile> {
        return self.userProfileRepository.fetchMyProfile()
    }
    
    func fetchUserProfile(with userID: String) -> Single<UserProfile> {
        return self.userProfileRepository.fetchProfileByUUID(userID)
    }
    
    func updateUserProfile(userProfile: UserProfile) {
        _ = self.userProfileRepository.updateMyProfile(userProfile)
    }
    
    func updateUserProfileCompletable(userProfile: UserProfile) -> Completable {
        self.userProfileRepository.updateMyProfile(userProfile).asCompletable()
    }
    
    func fetchUserProfiles(with userIDList: [String]) -> Single<[UserProfile]> {
        return self.userProfileRepository.fetchProfileByUUIDList(userIDList)
    }
}
