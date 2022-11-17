//
//  LaunchScreenRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/14.
//

import Foundation
import RxSwift

protocol LaunchScreenRepository {
    func verifyUser() -> Observable<Bool>
}
