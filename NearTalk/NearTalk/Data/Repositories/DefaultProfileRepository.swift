//
//  DefaultProfileRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/20.
//

import Foundation
import RxSwift

final class DefaultProfileRepository: ProfileRepository {
    private let firestoreService: FirestoreService
    private let firebaseAuthService: AuthService
    
    init(firestoreService: FirestoreService, firebaseAuthService: AuthService) {
        self.firestoreService = firestoreService
        self.firebaseAuthService = firebaseAuthService
    }
    
    func createMyProfile(_ userProfile: UserProfile) -> Single<UserProfile> {
        firebaseAuthService
            .fetchCurrentUserEmail()
            .flatMap { email in
                var newUserProfile: UserProfile = userProfile
                newUserProfile.email = email
                return self.firestoreService.create(data: newUserProfile, dataKey: .users)
            }
    }
    
    func fetchMyProfile() -> Single<UserProfile> {
        firebaseAuthService
            .fetchCurrentUserEmail()
            .flatMap {
                let query: [FirebaseQueryDTO] = [.init(key: "email", value: $0, queryKey: .isEqualTo)]
                return self.firestoreService.fetch(dataKey: .users, queryList: query)
            }
    }
    
    func updateMyProfile(_ userProfile: UserProfile) -> Single<UserProfile> {
        self.fetchMyProfile()
            .flatMap { (profile: UserProfile) in
                var newProfile: UserProfile = userProfile
                newProfile.uuid = profile.uuid
                newProfile.email = profile.email
                return self.firestoreService.update(updatedData: newProfile, dataKey: .users)
            }
    }
    
    func deleteMyProfile() -> Completable {
        self.fetchMyProfile()
            .flatMapCompletable { (userProfile: UserProfile) in
                return self.firestoreService.delete(data: userProfile, dataKey: .users)
            }
    }
    
    func addFriend(_ friendUUID: String) -> Completable {
        self.fetchMyProfile()
            .flatMap { (myProfile: UserProfile) -> Single<UserProfile> in
                var newProfile: UserProfile = myProfile
                if let friend = newProfile.friends, !friend.contains(friendUUID) {
                    newProfile.friends?.append(friendUUID)
                }
                return self.firestoreService.update(updatedData: newProfile, dataKey: .users)
            }
            .asCompletable()
    }
    
    func addChatRoom(_ chatRoomUUID: String) -> Completable {
        self.fetchMyProfile()
            .flatMap { (myProfile: UserProfile) -> Single<UserProfile> in
                var newProfile: UserProfile = myProfile
                if let chat = newProfile.chatRooms, !chat.contains(chatRoomUUID) {
                    newProfile.chatRooms?.append(chatRoomUUID)
                }
                return self.firestoreService.update(updatedData: newProfile, dataKey: .users)
            }
            .asCompletable()
    }
    
    func removeFriend(_ friendUUID: String) -> Completable {
        self.fetchMyProfile()
            .flatMap { (myProfile: UserProfile) -> Single<UserProfile> in
                var newProfile: UserProfile = myProfile
                newProfile.friends = newProfile.friends?.filter({ $0 != friendUUID })
                return self.firestoreService.update(updatedData: newProfile, dataKey: .users)
            }
            .asCompletable()
    }
    
    func fetchFriendsProfile() -> Single<[UserProfile]> {
        self.fetchMyProfile()
            .flatMap { (myProfile: UserProfile) in
                guard let friendList: [String] = myProfile.friends else {
                    return Single.error(DefaultProfileRepositoryError.invalidUserProfile)
                }
                if friendList.isEmpty {
                    return .just([])
                }
                let query: [FirebaseQueryDTO] = [.init(key: "uuid", value: friendList, queryKey: .in)]
                return self.firestoreService.fetchList(dataKey: .users, queryList: query)
            }
    }
    
    func fetchProfileByUUID(_ uuid: String) -> Single<UserProfile> {
        let query: [FirebaseQueryDTO] = [.init(key: "uuid", value: uuid, queryKey: .isEqualTo)]
        return self.firestoreService.fetch(dataKey: .users, queryList: query)
    }
    
    func fetchProfileByUUIDList(_ uuidList: [String]) -> Single<[UserProfile]> {
        let query: [FirebaseQueryDTO] = [.init(key: "uuid", value: uuidList, queryKey: .in)]
        return self.firestoreService.fetchList(dataKey: .users, queryList: query)
    }
    
    private func fetchProfileByEmail(_ email: String) -> Single<UserProfile> {
        let query: [FirebaseQueryDTO] = [.init(key: "email", value: email, queryKey: .isEqualTo)]
        return self.firestoreService.fetch(dataKey: .users, queryList: query)
    }
}

enum DefaultProfileRepositoryError: Error {
    case invalidUserProfile
}
