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
        self.container.register(MediaRepository.self) { resolver in
            DefaultMediaRepository(storageService: resolver.resolve(StorageService.self)!)
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
        self.container.register(UploadImageUseCase.self) { resolver in
            DefaultUploadImageUseCase(mediaRepository: resolver.resolve(MediaRepository.self)!)
        }
        self.container.register(CreateProfileUseCase.self) { resolver in
            DefaultCreateProfileUseCase(
                profileRepository: resolver.resolve(ProfileRepository.self)!,
                userDefaultsRepository: resolver.resolve(UserDefaultsRepository.self)!
            )
        }
    }
    
    // MARK: - ViewModel
    func registerViewModel(action: OnboardingViewModelAction) {
        self.container.register(OnboardingViewModel.self) { resolver in
            DefaultOnboardingViewModel(
                validateNickNameUseCase: resolver.resolve(
                    ValidateTextUseCase.self,
                    name: OnboardingDependencyName.nickname.rawValue
                )!,
                validateStatusMessageUseCase: resolver.resolve(
                    ValidateTextUseCase.self,
                    name: OnboardingDependencyName.statusMessage.rawValue
                )!,
                uploadImageUseCase: resolver.resolve(UploadImageUseCase.self)!,
                createProfileUseCase: resolver.resolve(CreateProfileUseCase.self)!,
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
