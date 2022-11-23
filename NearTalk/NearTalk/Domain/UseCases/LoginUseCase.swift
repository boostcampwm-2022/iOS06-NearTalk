//
//  LoginUseCase.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/20.
//

import Foundation
import RxSwift

protocol LoginUseCase {
    func login(token idTokenString: String, nonce: String) -> Completable
}

final class DefaultLoginUseCase: LoginUseCase {
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func login(token idTokenString: String, nonce: String) -> Completable {
        self.authService.loginWithApple(token: idTokenString, nonce: nonce)
    }
}
