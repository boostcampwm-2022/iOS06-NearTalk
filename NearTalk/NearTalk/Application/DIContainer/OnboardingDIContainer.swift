//
//  OnboardingDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/15.
//

import Foundation
import UIKit

final class DefaultOnboardingDIContainer {
    // MARK: - Dependencies
    func makeOnboardingCoordinatorDependency() -> any OnboardingCoordinatorDependency {
        return DefaultOnboardingCoordinatorDependency()
    }

    // MARK: - UseCases
    private func makeOnboardingValidateUseCase() -> OnboardingValidateUseCase {
        return DefaultOnboardingValidateUseCase()
    }
    
    private func makeOnboardingSaveProfileUseCase(respository: any UserProfileRepository) -> OnboardingSaveProfileUseCase {
        return DefaultOnboardingSaveProfileUseCase(repository: respository)
    }
    
    // MARK: - Repositories
    private func makeRepository() -> any UserProfileRepository {
        return DefaultUserProfileRepository()
    }
    
    // MARK: - ViewModels
    func makeViewModel() -> any OnboardingViewModel {
        return DefaultOnboardingViewModel(validateUseCase: makeOnboardingValidateUseCase(), saveProfileUseCase: makeOnboardingSaveProfileUseCase(respository: makeRepository()))
    }
    
    // MARK: - Create viewController
    func makeOnboardingViewController(coordinator: OnboardingCoordinator) -> OnboardingViewController {
        return OnboardingViewController(viewModel: makeViewModel(), coordinator: coordinator)
    }
    
    // MARK: - Coordinator
    func makeOnboardingCoordinator(
        navigationController: UINavigationController, dependency: any OnboardingCoordinatorDependency) -> OnboardingCoordinator {
        return OnboardingCoordinator(navigationController: navigationController, dependency: dependency)
    }
}
