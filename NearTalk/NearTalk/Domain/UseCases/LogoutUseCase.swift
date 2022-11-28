//
//  LogoutUseCase.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/21.
//

import Foundation
import RxSwift

protocol LogoutUseCase {
    init(authRepository: any AuthRepository)
    func execute() -> Completable
}

final class DefaultLogoutUseCase: LogoutUseCase {
    private let authRepository: any AuthRepository
    
    init(authRepository: any AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute() -> Completable {
        self.authRepository.logout()
    }
}
