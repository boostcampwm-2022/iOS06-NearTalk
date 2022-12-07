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
        self.registerVerifyUseCase()
        self.registerViewModel(loginAction: actions)
    }
    
    private func registerLoginUseCase() {
        self.container.register(LoginUseCase.self) { resolver in
            DefaultLoginUseCase(authRepository: resolver.resolve(AuthRepository.self)!)
        }
    }
    
    private func registerVerifyUseCase() {
        self.container.register(VerifyUserUseCase.self) { resolver in
            DefaultVerifyUserUseCase(
                authRepository: resolver.resolve(AuthRepository.self)!,
                profileRepository: resolver.resolve(ProfileRepository.self)!,
                userDefaultsRepository: resolver.resolve(UserDefaultsRepository.self)!
            )
        }
    }
    
    private func registerViewModel(loginAction: LoginAction) {
        self.container.register(LoginViewModel.self) { resolver in
            DefaultLoginViewModel(
                action: loginAction,
                loginUseCase: resolver.resolve(LoginUseCase.self)!,
                verifyUseCase: resolver.resolve(VerifyUserUseCase.self)!
            )
        }
    }
    
    func resolveLoginViewController() -> LoginViewController {
        LoginViewController(viewModel: self.container.resolve(LoginViewModel.self)!)
    }
}
