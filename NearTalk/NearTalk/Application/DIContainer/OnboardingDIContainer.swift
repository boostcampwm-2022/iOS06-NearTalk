//
//  OnboardingDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/15.
//

import Swinject
import UIKit

final class DefaultOnboardingDIContainer {
    private let container: Container
    let showMainViewController: (() -> Void)?
    
    init(container: Container, showMainViewController: (() -> Void)?) {
        self.container = Container(parent: container)
        self.showMainViewController = showMainViewController
        self.registerService()
        self.registerRepository()
        self.registerUseCase()
//        self.registerViewModel(action: action)
    }
    
    // MARK: - Service
    private func registerService() {
        self.container.register(StorageService.self) { _ in DefaultStorageService() }
    }

    // MARK: - Repository
    private func registerRepository() {
        self.container.register(MediaRepository.self) { _ in
            DefaultMediaRepository(storageService: self.container.resolve(StorageService.self)!)
        }
    }

    // MARK: - UseCases
    private func registerUseCase() {
        self.container.register(
            ValidateTextUseCase.self,
            name: OnboardingDependencyName.nickname.rawValue
        ) { _ in ValidateNickNameUseCase() }
        self.container.register(
            ValidateTextUseCase.self,
            name: OnboardingDependencyName.statusMessage.rawValue
        ) { _ in ValidateStatusMessageUseCase() }
        self.container.register(UploadImageUseCase.self) { _ in
            DefaultUploadImageUseCase(mediaRepository: self.container.resolve(MediaRepository.self)!)
        }
        self.container.register(CreateProfileUseCase.self) { _ in
            DefaultCreateProfileUseCase(
                profileRepository: self.container.resolve(ProfileRepository.self)!,
                authRepository: self.container.resolve(AuthRepository.self)!
            )
        }
    }
    
    // MARK: - ViewModel
    func registerViewModel(action: OnboardingViewModelAction) {
        self.container.register(OnboardingViewModel.self) { _ in
            DefaultOnboardingViewModel(
                validateNickNameUseCase: self.container.resolve(
                    ValidateTextUseCase.self,
                    name: OnboardingDependencyName.nickname.rawValue
                )!,
                validateStatusMessageUseCase: self.container.resolve(
                    ValidateTextUseCase.self,
                    name: OnboardingDependencyName.statusMessage.rawValue
                )!,
                uploadImageUseCase: self.container.resolve(UploadImageUseCase.self)!,
                createProfileUseCase: self.container.resolve(CreateProfileUseCase.self)!,
                action: action
            )
        }
    }
    
    // MARK: - Create viewController
    func resolveOnboardingViewController() -> OnboardingViewController {
        return OnboardingViewController(viewModel: self.container.resolve(OnboardingViewModel.self)!)
    }
}

enum OnboardingDependencyName: String {
    case nickname
    case statusMessage
}
