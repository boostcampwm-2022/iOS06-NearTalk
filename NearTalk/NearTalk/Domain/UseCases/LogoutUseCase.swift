//
//  LogoutUseCase.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/21.
//

import Foundation
import RxSwift

protocol LogoutUseCase {
    func logout() -> Completable
}

final class DefaultLogoutUseCase: LogoutUseCase {
    private let authService: FirebaseAuthService
    
    init(authService: FirebaseAuthService) {
        self.authService = authService
    }
    
    func logout() -> Completable {
        self.authService.logout()
    }
}
