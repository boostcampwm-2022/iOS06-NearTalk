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
    func requestLogin()
    func requestFireBaseLogin(token: String)
}

protocol LoginAction {
    var presentLoginView: (() -> Void)? { get }
    var loginSuccess: (() -> Void)? { get }
    var presentLoginFailure: (() -> Void)? { get }
}

protocol LoginViewModel: LoginInput {}

final class DefaultLoginViewModel: LoginViewModel {
    func requestFireBaseLogin(token: String) {
        self.loginUseCase.login(token: token)
            .subscribe { [weak self] in
                self?.action.loginSuccess?()
            } onError: { [weak self] _ in
                self?.action.presentLoginFailure?()
            }
            .disposed(by: self.disposeBag)
    }
    
    func requestLogin() {
        self.action.presentLoginView?()
    }
    
    private let action: any LoginAction
    private let loginUseCase: any LoginUseCase
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(action: any LoginAction, loginUseCase: any LoginUseCase) {
        self.action = action
        self.loginUseCase = loginUseCase
    }
}
