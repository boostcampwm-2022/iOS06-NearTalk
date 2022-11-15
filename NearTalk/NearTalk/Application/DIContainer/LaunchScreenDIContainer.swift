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

    // MARK: - UseCases
    private func makeLaunchScreenUseCase() -> LaunchScreenUseCase {
        return DefaultLaunchScreenUseCase(launchScreenRepository: DefaultLaunchScreenRepository())
    }
    
    // MARK: - Repositories
    private func makeRepository() -> LaunchScreenRepository {
        return DefaultLaunchScreenRepository()
    }
    
    // MARK: - ViewModels
    private func makeViewModel(actions: LaunchScreenViewModelActions) -> LaunchScreenViewModel {
        return DefaultLaunchScreenViewModel(
            useCase: makeLaunchScreenUseCase(),
            actions: actions
        )
    }
    
    // MARK: - Create viewController
    func createLaunchScreenViewController(actions: LaunchScreenViewModelActions) -> LaunchScreenViewController {
        return LaunchScreenViewController(
            viewModel: makeViewModel(actions: actions),
            repository: makeRepository()
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
