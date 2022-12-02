//
//  LoginViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import Foundation
import RxRelay
import RxSwift

protocol LoginInput {
    func requestFireBaseLogin(token: String)
}

struct LoginAction {
    var presentMainView: (() -> Void)?
    var presentOnboardingView: (() -> Void)?
    var presentLoginFailure: (() -> Void)?
}

protocol LoginViewModel: LoginInput {}

final class DefaultLoginViewModel: LoginViewModel {
    func requestFireBaseLogin(token: String) {
        self.loginUseCase.login(token: token)
            .subscribe { [weak self] in
                self?.requestProfileExistence()
            } onError: { [weak self] _ in
                self?.action.presentLoginFailure?()
            }
            .disposed(by: self.disposeBag)
    }
    
    func requestProfileExistence() {
        self.verifyUseCase.verifyProfile()
            .subscribe { [weak self] in
                self?.action.presentMainView?()
            } onError: { [weak self] _ in
                self?.action.presentOnboardingView?()
            }
            .disposed(by: self.disposeBag)
    }
    
    private let action: LoginAction
    private let loginUseCase: any LoginUseCase
    private let verifyUseCase: any VerifyUserUseCase
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(action: LoginAction,
         loginUseCase: any LoginUseCase,
         verifyUseCase: any VerifyUserUseCase) {
        self.action = action
        self.loginUseCase = loginUseCase
        self.verifyUseCase = verifyUseCase
    }
}
