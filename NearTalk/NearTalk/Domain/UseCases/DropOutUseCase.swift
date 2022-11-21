//
//  DropOutUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift

protocol DropoutUseCase {
    func dropout() -> Completable
    init(authRepository: AuthRepository)
}

final class DefaultDropOutUseCase: DropoutUseCase {
    private let authRepository: any AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func dropout() -> Completable {
        return self.authRepository.dropout()
    }
}
