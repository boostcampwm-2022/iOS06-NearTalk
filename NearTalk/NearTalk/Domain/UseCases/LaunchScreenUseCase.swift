//
//  LaunchScreenUseCase.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/14.
//

import Foundation
import RxSwift

protocol LaunchScreenUseCase {
    func verifyUser() -> Observable<Bool>
}

final class DefaultLaunchScreenUseCase: LaunchScreenUseCase {
    private let launchScreenRepository: LaunchScreenRepository
    
    init(launchScreenRepository: LaunchScreenRepository) {
        self.launchScreenRepository = launchScreenRepository
    }
    
    func verifyUser() -> Observable<Bool> {
        self.launchScreenRepository.verifyUser()
    }
}
