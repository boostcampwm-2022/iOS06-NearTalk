//
//  LaunchScreenDIContainer.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/13.
//

import Swinject
import UIKit

/// LaunchScreenViewController에 필요한 의존성을 주입해주는 클래스
final class LaunchScreenDIContainer {
    private let container: Container
    
    init(
        container: Container,
        navigationController: UINavigationController,
        actions: LaunchScreenViewModelActions
    ) {
        self.container = Container(parent: container)
        self.registerUseCase()
        self.registerViewModel(actions: actions)
    }
    
    private func registerUseCase() {
        self.container.register(VerifyUserUseCase.self) { resolver in
            DefaultVerifyUserUseCase(
                authRepository: resolver.resolve(AuthRepository.self)!,
                profileRepository: resolver.resolve(ProfileRepository.self)!,
                userDefaultsRepository: resolver.resolve(UserDefaultsRepository.self)!
            )
        }
    }
    
    private func registerViewModel(actions: LaunchScreenViewModelActions) {
        self.container.register(LaunchScreenViewModel.self) { resolver in
            DefaultLaunchScreenViewModel(
                useCase: resolver.resolve(VerifyUserUseCase.self)!,
                actions: actions
            )
        }
    }
    
    // MARK: - Create viewController
    func resolveLaunchScreenViewController() -> LaunchScreenViewController {
        return LaunchScreenViewController(viewModel: self.container.resolve(LaunchScreenViewModel.self)!)
    }
}
