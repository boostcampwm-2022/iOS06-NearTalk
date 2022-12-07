//
//  AuthService.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/22.
//

import Foundation
import RxSwift

protocol AuthService {
    func verifyUser() -> Completable
    func fetchCurrentUserEmail() -> Single<String>
    func loginWithApple(token idTokenString: String, nonce: String) -> Completable
    func logout() -> Completable
    func deleteCurrentUser() -> Completable
    func reauthenticateUser(idTokenString: String, nonce: String?) -> Completable
}
