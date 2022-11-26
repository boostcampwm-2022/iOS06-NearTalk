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
    
    init(container: Container, action: OnboardingViewModelAction) {
        self.container = Container(parent: container)
        
        self.registerService()
        self.registerRepository()
        self.registerUseCase()
        self.registerViewModel(action: action)
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
        self.container.register(ValidateTextUseCase.self, name: "nickname") { _ in ValidateNickNameUseCase() }
        self.container.register(ValidateTextUseCase.self, name: "statusMessage") { _ in ValidateStatusMessageUseCase() }
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
    private func registerViewModel(action: OnboardingViewModelAction) {
        self.container.register(OnboardingViewModel.self) { _ in
            DefaultOnboardingViewModel(
                validateNickNameUseCase: self.container.resolve(ValidateTextUseCase.self, name: "nickname")!,
                validateStatusMessageUseCase: self.container.resolve(ValidateTextUseCase.self, name: "statusMessage")!,
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
