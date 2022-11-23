//
//  OnboardingDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/15.
//

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
    
    private func makeOnboardingSaveProfileUseCase(
        profileRepository: any UserProfileRepository,
        uuidRepository: any UserUUIDRepository,
        imageRepository: any ImageRepository) -> OnboardingSaveProfileUseCase {
        return DefaultOnboardingSaveProfileUseCase(
            profileRepository: profileRepository,
            uuidRepository: uuidRepository,
            imageRepository: imageRepository)
    }
    
    // MARK: - Repositories
    private func makeProfileRepository() -> any UserProfileRepository {
        return DefaultUserProfileRepository()
    }
    
    private func makeUserUUIDRepository() -> any UserUUIDRepository {
        return DefaultUserUUIDRepository()
    }
    
    private func makeImageRepository() -> any ImageRepository {
        return DefaultImageRepository()
    }
    
    // MARK: - ViewModels
    func makeViewModel() -> any OnboardingViewModel {
        return DefaultOnboardingViewModel(
            validateUseCase: makeOnboardingValidateUseCase(),
            saveProfileUseCase: makeOnboardingSaveProfileUseCase(
                profileRepository: self.makeProfileRepository(),
                uuidRepository: self.makeUserUUIDRepository(),
                imageRepository: self.makeImageRepository()))
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
