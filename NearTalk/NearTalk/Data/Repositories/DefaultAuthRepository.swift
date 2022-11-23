//
//  DefaultAuthRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift

final class DefaultAuthRepository: AuthRepository {
    private let authService: any AuthService
    
    init(authService: any AuthService) {
        self.authService = authService
    }
    
    func logout() -> Completable {
        return self.authService.logout()
    }
    
    func dropout() -> Completable {
        return self.authService.deleteCurrentUser()
    }
}
