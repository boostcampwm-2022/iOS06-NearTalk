//
//  LogoutUseCase.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/21.
//

import Foundation
import RxSwift

protocol LogoutUseCase {
    init(authRepository: any AuthRepository, userDefaultsRepository: any UserDefaultsRepository)
    func logout() -> Completable
}

final class DefaultLogoutUseCase: LogoutUseCase {
    private let authRepository: any AuthRepository
    private let userDefaultsRepository: any UserDefaultsRepository
    
    init(authRepository: any AuthRepository, userDefaultsRepository: any UserDefaultsRepository) {
        self.authRepository = authRepository
        self.userDefaultsRepository = userDefaultsRepository
    }
    
    func logout() -> Completable {
        userDefaultsRepository.removeUserProfile()
        return self.authRepository.logout()
    }
}
