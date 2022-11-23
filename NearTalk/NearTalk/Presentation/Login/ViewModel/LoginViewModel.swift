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
}

protocol LoginAction {
    var presentLoginView: (() -> Void)? { get }
}

protocol LoginViewModel: LoginInput {}

final class DefaultLoginViewModel: LoginViewModel {
    func requestLogin() {
        self.action.presentLoginView?()
    }
    
    private let action: any LoginAction
    private let loginUseCase: any LoginUseCase
    
    init(action: any LoginAction, loginUseCase: any LoginUseCase) {
        self.action = action
        self.loginUseCase = loginUseCase
    }
}
