//
//  LoginDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import Swinject
import UIKit

final class LoginDIContainer {
    private let container: Container
    
    init(container: Container, navigationController: UINavigationController, actions: LoginAction) {
        self.container = Container(parent: container)
        
        self.registerLoginUseCase()
        self.registerViewModel(loginAction: actions)
    }
    
    private func registerLoginUseCase() {
        self.container.register(LoginUseCase.self) { _ in
            DefaultLoginUseCase(authRepository: self.container.resolve(AuthRepository.self)!)
        }
    }
    
    private func registerViewModel(loginAction: LoginAction) {
        self.container.register(LoginViewModel.self) { _ in
            DefaultLoginViewModel(
                action: loginAction,
                loginUseCase: self.container.resolve(LoginUseCase.self)!
            )
        }
    }
    
    func resolveLoginViewController() -> LoginViewController {
        LoginViewController(viewModel: self.container.resolve(LoginViewModel.self)!)
    }
}
