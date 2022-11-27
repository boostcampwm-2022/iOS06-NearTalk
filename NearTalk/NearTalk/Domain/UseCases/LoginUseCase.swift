//
//  LoginUseCase.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/20.
//

import Foundation
import RxSwift

protocol LoginUseCase {
    func login(token idTokenString: String) -> Completable
}

final class DefaultLoginUseCase: LoginUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func login(token idTokenString: String) -> Completable {
        self.authRepository.login(token: idTokenString)
    }
}
