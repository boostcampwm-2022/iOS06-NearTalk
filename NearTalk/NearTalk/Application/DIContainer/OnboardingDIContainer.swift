//
//  OnboardingDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/15.
//

import UIKit

final class DefaultOnboardingDIContainer: OnboardingCoordinatorDependency {
    private let dependency: Dependency
    
    struct Dependency {
        let showMainViewController: (() -> Void)?
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func showMainViewController() {
        self.dependency.showMainViewController?()
    }
    
    // MARK: - Service
    func makeStorageService() -> any StorageService {
        return DefaultStorageService()
    }
    
    func makeAuthService() -> any AuthService {
        return DefaultFirebaseAuthService()
    }
    
    func makeFirestoreService() -> any FirestoreService {
        return DefaultFirestoreService()
    }
    
    // MARK: - Repository
    func makeMediaRepository() -> any MediaRepository {
        return DefaultMediaRepository(storageService: self.makeStorageService())
    }
    
    func makeAuthRepository() -> any AuthRepository {
        return DefaultAuthRepository(authService: makeAuthService())
    }
    
    func makeProfileRepository() -> any ProfileRepository {
        return DefaultProfileRepository(firestoreService: makeFirestoreService(), firebaseAuthService: makeAuthService())
    }
    
    // MARK: - UseCases
    private func makeValidateNickNameUseCase() -> any ValidateTextUseCase {
        return ValidateNickNameUseCase()
    }
    
    private func makeValidateStatusMessageUseCase() -> any ValidateTextUseCase {
        return ValidateStatusMessageUseCase()
    }
    
    private func makeUploadImageUseCase() -> any UploadImageUseCase {
        return DefaultUploadImageUseCase(mediaRepository: self.makeMediaRepository())
    }
    
    private func makeCreateProfileUseCase() -> any CreateProfileUseCase {
        return DefaultCreateProfileUseCase(profileRepository: self.makeProfileRepository(), authRepository: self.makeAuthRepository())
    }
    
    // MARK: - Create viewController
    func makeOnboardingViewController(action: OnboardingViewModelAction) -> OnboardingViewController {
        let viewModel: any OnboardingViewModel = DefaultOnboardingViewModel(
            validateNickNameUseCase: self.makeValidateNickNameUseCase(),
            validateStatusMessageUseCase: self.makeValidateStatusMessageUseCase(),
            uploadImageUseCase: self.makeUploadImageUseCase(),
            createProfileUseCase: self.makeCreateProfileUseCase(),
            action: action
        )
        return OnboardingViewController(viewModel: viewModel)
    }
    
    // MARK: - Coordinator
    func makeOnboardingCoordinator(
        navigationController: UINavigationController?,
        parent: Coordinator
    ) -> OnboardingCoordinator {
        return OnboardingCoordinator(navigationController: navigationController, parentCoordinator: parent, dependency: self)
    }
}
