//
//  DummyAuthRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import Foundation
import RxSwift

enum DummyAuthRepositoryError: Error {
    case nilUser
}

final class DummyAuthRepository: AuthRepository {
    func verify() -> RxSwift.Completable {
        return Completable.create { completable in
            completable(.completed)
            return Disposables.create()
        }
    }
    
    static private let uidKey: String = "MyUID"
    
    func logout() -> RxSwift.Completable {
        return Completable.create { completable in
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func dropout() -> RxSwift.Completable {
        return Completable.create { completable in
            UserDefaults.standard.removeObject(forKey: DummyAuthRepository.uidKey)
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func login(token: String) -> RxSwift.Completable {
        return Completable.create { completable in
            if UserDefaults.standard.string(forKey: DummyAuthRepository.uidKey) == nil {
                UserDefaults.standard.set(UUID().uuidString, forKey: DummyAuthRepository.uidKey)
            }
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func fetchCurrentUserUID() -> RxSwift.Single<String> {
        return Single<String>.create { single in
            guard let uid = UserDefaults.standard.string(forKey: DummyAuthRepository.uidKey) else {
                single(.failure(DummyAuthRepositoryError.nilUser))
                return Disposables.create()
            }
            single(.success(uid))
            return Disposables.create()
        }
    }
    
    func reauthenticate(token: String) -> Completable {
        Completable.create { completable in
            completable(.completed)
            return Disposables.create()
        }
    }
}
