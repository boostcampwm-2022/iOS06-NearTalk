//
//  LaunchScreenViewModel.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/14.
//

import Foundation
import RxSwift

struct LaunchScreenViewModelActions {
    var showLoginViewController: (() -> Void)?
    var showOnboardingView: (() -> Void)?
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
    let hasProfile: PublishSubject<Bool>
    private let disposeBag: DisposeBag
    
    init(useCase: VerifyUserUseCase, actions: LaunchScreenViewModelActions) {
        self.useCase = useCase
        self.actions = actions
        self.isUserAuthenticated = PublishSubject<Bool>()
        self.hasProfile = PublishSubject<Bool>()
        self.disposeBag = DisposeBag()
        self.bindAuthResult()
        self.bindProfile()
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
    
    private func checkHasProfile() {
        self.useCase.verifyProfile()
            .subscribe(
                onCompleted: { [weak self] in
                    guard let self else {
                        return
                    }
                    self.hasProfile.onNext(true)
                },
                onError: { [weak self] error in
                    guard let self else {
                        return
                    }
                    print(error)
                    self.hasProfile.onNext(false)
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    private func bindAuthResult() {
        self.isUserAuthenticated
            .subscribe { [weak self] isAuthenticated in
                guard let self else {
                    return
                }
                if isAuthenticated {
                    self.checkHasProfile()
                } else {
                    self.actions.showLoginViewController?()
                }
            }.disposed(by: disposeBag)
    }
    
    private func bindProfile() {
        self.hasProfile
            .subscribe { [weak self] hasProfile in
                guard let self else {
                    return
                }
                if hasProfile {
                    self.actions.showMainViewController?()
                } else {
                    self.actions.showOnboardingView?()
                }
            }.disposed(by: disposeBag)
    }
}
