//
//  VerifyUserUseCase.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/21.
//

import Foundation
import RxSwift

protocol VerifyUserUseCase {
    func verifyUser() -> Completable
}

final class DefaultVerifyUserUseCase: VerifyUserUseCase {
    private let authService: FirebaseAuthService
    
    init(authService: FirebaseAuthService) {
        self.authService = authService
    }
    
    func verifyUser() -> Completable {
        self.authService.verifyUser()
    }
}
