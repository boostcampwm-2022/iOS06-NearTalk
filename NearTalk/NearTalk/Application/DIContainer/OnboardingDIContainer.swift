//
//  OnboardingDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/15.
//

import UIKit

final class DefaultOnboardingDIContainer: OnboardingCoordinatorDependency {
    private let dependency: Depenency
    
    init(dependency: Depenency) {
        self.dependency = dependency
    }
    
    struct Depenency {
        let imageRepository: any ImageRepository
        let profileRepository: any ProfileRepository
        let showMainViewController: (() -> Void)?
        let email: String?
    }
    
    func showMainViewController() {
        self.dependency.showMainViewController?()
    }
    
    // MARK: - UseCases
    private func makeValidateNickNameUseCase() -> any ValidateTextUseCase {
        return ValidateNickNameUseCase()
    }
    
    private func makeValidateStatusMessageUseCase() -> any ValidateTextUseCase {
        return ValidateStatusMessageUseCase()
    }
    
    private func makeUploadImageUseCase() -> any UploadImageUseCase {
        return DefaultUploadImageUseCase(imageRepository: self.dependency.imageRepository)
    }
    
    private func makeCreateProfileUseCase() -> any CreateProfileUseCase {
        return DefaultCreateProfileUseCase(profileRepository: self.dependency.profileRepository)
    }
    
    // MARK: - Create viewController
    func makeOnboardingViewController(action: OnboardingViewModelAction) -> OnboardingViewController {
        let viewModel: any OnboardingViewModel = DefaultOnboardingViewModel(
            validateNickNameUseCase: self.makeValidateNickNameUseCase(),
            validateStatusMessageUseCase: self.makeValidateStatusMessageUseCase(),
            uploadImageUseCase: self.makeUploadImageUseCase(),
            createProfileUseCase: self.makeCreateProfileUseCase(),
            action: action,
            email: self.dependency.email)
        return OnboardingViewController(viewModel: viewModel)
    }
    
    // MARK: - Coordinator
    func makeOnboardingCoordinator(
        navigationController: UINavigationController?) -> OnboardingCoordinator {
            return OnboardingCoordinator(navigationController: navigationController, dependency: self)
    }
}
