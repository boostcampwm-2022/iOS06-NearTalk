//
//  DefaultLaunchScreenRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/14.
//

import Foundation
import RxSwift

final class DefaultLaunchScreenRepository: LaunchScreenRepository {
    func fetchCredential() -> Observable<Bool> {
        Observable<Bool>.create { observer in
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }
    }
}
