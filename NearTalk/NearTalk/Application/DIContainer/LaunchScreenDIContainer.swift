//
//  LaunchScreenDIContainer.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/13.
//

import Foundation
import UIKit

/// LaunchScreenViewController에 필요한 의존성을 주입해주는 클래스
final class LaunchScreenDIContainer {
    // MARK: - Dependencies
    
    // MARK: - Services
    func makeAuthService() -> FirebaseAuthService {
        return DefaultFirebaseAuthService()
    }
    
    // MARK: - UseCases
    func makeLoginUseCase() -> LoginUseCase {
        return DefaultLoginUseCase(authService: makeAuthService())
    }
    
    // MARK: - Repositories
    
    // MARK: - ViewModels
    func makeViewModel(actions: LaunchScreenViewModelActions) -> LaunchScreenViewModel {
        return DefaultLaunchScreenViewModel(useCase: self.makeLoginUseCase(), actions: actions)
    }
    
    // MARK: - Create viewController
    func createLaunchScreenViewController(actions: LaunchScreenViewModelActions) -> LaunchScreenViewController {
        return LaunchScreenViewController(viewModel: self.makeViewModel(actions: actions))
    }
    
    // MARK: - Coordinator
    func makeLaunchScreenCoordinator(
        navigationController: UINavigationController,
        dependency: LaunchScreenCoordinatorDependency
    ) -> LaunchScreenCoordinator {
        return LaunchScreenCoordinator(navigationController: navigationController, dependency: dependency)
    }
}
