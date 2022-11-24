//
//  DummyVerifyUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import RxSwift

final class DummyVerifyUseCase: VerifyUserUseCase {
    func verifyUser() -> Completable {
        return Completable.create { completable in
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func verifyProfile() -> Completable {
        return Completable.create { completable in
            completable(.completed)
            return Disposables.create()
        }
    }
}
