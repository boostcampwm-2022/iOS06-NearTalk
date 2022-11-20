//
//  LoginUseCase.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/20.
//

import Foundation
import RxSwift

protocol LoginUseCase {
    func verifyUser() -> Completable
    func login(token idTokenString: String, nonce: String) -> Completable
    func logout() -> Completable
}

final class DefaultLoginUseCase: LoginUseCase {
    private let authService: FirebaseAuthService
    
    init(authService: FirebaseAuthService) {
        self.authService = authService
    }
    
    func verifyUser() -> Completable {
        self.authService.verifyUser()
    }
    
    func login(token idTokenString: String, nonce: String) -> Completable {
        self.authService.loginWithApple(token: idTokenString, nonce: nonce)
    }
    
    func logout() -> Completable {
        self.authService.logout()
    }
}
