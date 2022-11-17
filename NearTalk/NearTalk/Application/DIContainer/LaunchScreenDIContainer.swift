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

    // MARK: - UseCases
    func makeLaunchScreenUseCase() -> LaunchScreenUseCase {
        return DefaultLaunchScreenUseCase(launchScreenRepository: self.makeRepository())
    }
    
    // MARK: - Repositories
    func makeRepository() -> LaunchScreenRepository {
        return DefaultLaunchScreenRepository(firebaseAuthService: DefaultFirebaseAuthService())
    }
    
    // MARK: - ViewModels
    func makeViewModel(actions: LaunchScreenViewModelActions) -> LaunchScreenViewModel {
        return DefaultLaunchScreenViewModel(
            useCase: self.makeLaunchScreenUseCase(),
            actions: actions
        )
    }
    
    // MARK: - Create viewController
    func createLaunchScreenViewController(actions: LaunchScreenViewModelActions) -> LaunchScreenViewController {
        return LaunchScreenViewController(
            viewModel: self.makeViewModel(actions: actions),
            repository: self.makeRepository()
        )
    }
    
    // MARK: - Coordinator
    func makeLaunchScreenCoordinator(
        navigationController: UINavigationController,
        dependency: LaunchScreenCoordinatorDependency
    ) -> LaunchScreenCoordinator {
        return LaunchScreenCoordinator(navigationController: navigationController, dependency: dependency)
    }
}
