//
//  DefaultLaunchScreenRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/14.
//

import Foundation
import RxSwift

final class DefaultLaunchScreenRepository: LaunchScreenRepository {
    private let firebaseAuthService: FirebaseAuthService
    
    init(firebaseAuthService: FirebaseAuthService) {
        self.firebaseAuthService = firebaseAuthService
    }
    
    func verifyUser() -> Observable<Bool> {
        self.firebaseAuthService.verifyUser()
    }
}
