//
//  DropOutUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift

protocol DropoutUseCase {
    func dropout() -> Completable
    init(authRepository: AuthRepository, userDefaultsRepository: any UserDefaultsRepository)
}

final class DefaultDropOutUseCase: DropoutUseCase {
    private let authRepository: any AuthRepository
    private let userDefaultsRepository: any UserDefaultsRepository
    
    init(authRepository: AuthRepository, userDefaultsRepository: any UserDefaultsRepository) {
        self.authRepository = authRepository
        self.userDefaultsRepository = userDefaultsRepository
    }
    
    func dropout() -> Completable {
        userDefaultsRepository.removeUserProfile()
        return self.authRepository.dropout()
    }
}
