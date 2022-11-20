//
//  LaunchScreenUseCase.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/14.
//

import Foundation
import RxSwift

#warning("지워야하는 파일")
protocol LaunchScreenUseCase {
    func verifyUser() -> Completable
}

final class DefaultLaunchScreenUseCase: LaunchScreenUseCase {
    private let launchScreenRepository: LaunchScreenRepository
    
    init(launchScreenRepository: LaunchScreenRepository) {
        self.launchScreenRepository = launchScreenRepository
    }
    
    func verifyUser() -> Completable {
        self.launchScreenRepository.verifyUser()
    }
}
