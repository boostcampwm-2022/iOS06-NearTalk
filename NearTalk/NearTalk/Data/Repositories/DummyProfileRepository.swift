//
//  DummyProfileRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import Foundation
import RxSwift

enum DummyProfileRepoError: Error {
    case notFound
    case uuidNotGiven
    case encodeFailed
    case decodeFailed
}

final class DummyProfileRepository: ProfileRepository {
    func addChatRoom(_ chatRoomUUID: String) -> RxSwift.Completable {
        return Completable.create { completable in
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func fetchProfileByUUIDList(_ uuidList: [String]) -> RxSwift.Single<[UserProfile]> {
        return .just([])
    }
    
    private func encode(profile: UserProfile) -> Data? {
        let jsonEncoder: JSONEncoder = JSONEncoder()
        return try? jsonEncoder.encode(profile)
    }
    
    private func decode(data: Data) -> UserProfile? {
        let jsonDecoder: JSONDecoder = JSONDecoder()
        return try? jsonDecoder.decode(UserProfile.self, from: data)
    }
    
    func createMyProfile(_ userProfile: UserProfile) -> Single<UserProfile> {
        return Single.create { single in
            guard let data = self.encode(profile: userProfile) else {
                single(.failure(DummyProfileRepoError.encodeFailed))
                return Disposables.create()
            }
            UserDefaults.standard.set(data, forKey: "MyProfile")
            single(.success(userProfile))
            return Disposables.create()
        }
    }
    
    func fetchMyProfile() -> Single<UserProfile> {
        return Single.create { single in
            guard let encodedData = UserDefaults.standard.object(forKey: "MyProfile") as? Data else {
                single(.failure(DummyProfileRepoError.notFound))
                return Disposables.create()
            }
            guard let profile = self.decode(data: encodedData) else {
                single(.failure(DummyProfileRepoError.decodeFailed))
                return Disposables.create()
            }
            single(.success(profile))
            return Disposables.create()
        }
    }
    
    func updateMyProfile(_ userProfile: UserProfile) -> Single<UserProfile> {
        return Single.create { single in
            guard UserDefaults.standard.object(forKey: "MyProfile") as? Data != nil else {
                single(.failure(DummyProfileRepoError.notFound))
                return Disposables.create()
            }
            guard let encodedFile = self.encode(profile: userProfile) else {
                single(.failure(DummyProfileRepoError.encodeFailed))
                return Disposables.create()
            }
            UserDefaults.standard.set(encodedFile, forKey: "MyProfile")
            single(.success(userProfile))
            return Disposables.create()
        }
    }
    
    func deleteMyProfile() -> Completable {
        return Completable.create { completable in
            guard UserDefaults.standard.object(forKey: "MyProfile") as? Data != nil else {
                completable(.error(DummyProfileRepoError.notFound))
                return Disposables.create()
            }
            UserDefaults.standard.removeObject(forKey: "MyProfile")
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func addFriend(_ friendUUID: String) -> Completable {
        return Completable.create { completable in
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func removeFriend(_ friendUUID: String) -> Completable {
        return Completable.create { completable in
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func fetchFriendsProfile() -> Single<[UserProfile]> {
        return Single.create { single in
            single(.failure(DummyProfileRepoError.notFound))
            return Disposables.create()
        }
    }
    
    func fetchProfileByUUID(_ uuid: String) -> Single<UserProfile> {
        return Single.create { single in
            guard let encodedFile = UserDefaults.standard.object(forKey: uuid) as? Data else {
                single(.failure(DummyProfileRepoError.notFound))
                return Disposables.create()
            }
            guard let profile = self.decode(data: encodedFile) else {
                single(.failure(DummyProfileRepoError.decodeFailed))
                return Disposables.create()
            }
            single(.success(profile))
            return Disposables.create()
        }
    }
}
