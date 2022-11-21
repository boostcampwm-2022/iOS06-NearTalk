//
//  LaunchScreenViewModel.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/14.
//

import Foundation
import RxCocoa
import RxSwift

struct LaunchScreenViewModelActions {
    var showLoginViewController: (() -> Void)?
    var showMainViewController: (() -> Void)?
}

protocol LaunchScreenViewModelInput {
    func checkIsAuthenticated()
}

protocol LaunchScreenViewModelOutput {
    var isUserAuthenticated: PublishSubject<Bool> { get }
}

protocol LaunchScreenViewModel: LaunchScreenViewModelInput, LaunchScreenViewModelOutput {
    
}

final class DefaultLaunchScreenViewModel: LaunchScreenViewModel {
    private let useCase: VerifyUserUseCase
    private let actions: LaunchScreenViewModelActions

    let isUserAuthenticated: PublishSubject<Bool>
    private let disposeBag: DisposeBag
    
    init(useCase: VerifyUserUseCase, actions: LaunchScreenViewModelActions) {
        self.useCase = useCase
        self.actions = actions
        self.isUserAuthenticated = PublishSubject<Bool>()
        self.disposeBag = DisposeBag()
        self.bindAuthResult()
    }
    
    func checkIsAuthenticated() {
        self.useCase.verifyUser()
            .subscribe(
                onCompleted: { [weak self] in
                    guard let self else {
                        return
                    }
                    self.isUserAuthenticated.onNext(true)
                },
                onError: { [weak self] error in
                    guard let self else {
                        return
                    }
                    print(error)
                    self.isUserAuthenticated.onNext(false)
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    func bindAuthResult() {
        self.isUserAuthenticated
            .subscribe { [weak self] isAuthenticated in
                guard let self else {
                    return
                }
                if isAuthenticated {
                    self.actions.showMainViewController?()
                } else {
                    self.actions.showLoginViewController?()
                }
            }.disposed(by: disposeBag)
    }
}
