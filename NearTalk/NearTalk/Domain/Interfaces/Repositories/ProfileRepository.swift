//
//  ProfileRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/20.
//

import Foundation
import RxSwift

protocol ProfileRepository {
    func createMyProfile(_ userProfile: UserProfile) -> Single<UserProfile>
    func fetchMyProfile() -> Single<UserProfile>
    func updateMyProfile(_ userProfile: UserProfile) -> Single<UserProfile>
    func deleteMyProfile() -> Completable
    
    func addFriend(_ friendUUID: String) -> Completable
    func removeFriend(_ friendUUID: String) -> Completable
    func fetchFriendsProfile() -> Single<[UserProfile]>
    func fetchProfileByUUID(_ uuid: String) -> Single<UserProfile>
    func fetchProfileByUUIDList(_ uuidList: [String]) -> Single<[UserProfile]>
}
