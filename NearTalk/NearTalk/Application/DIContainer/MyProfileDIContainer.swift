//
//  MyProfileDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/16.
//

import Foundation

final class MyProfileDIContainer {
    // MARK: - Dependencies
    
    // MARK: - Services

    // MARK: - UseCases
    func makeMyProfileUseCase() -> MyProfileLoadUseCase {
        return DefaultMyProfileLoadUseCase(
            profileRepository: self.makeProfileRepository(),
            uuidRepository: self.makeUUIDRepository(),
            imageRepository: self.makeImageRepository()
        )
    }
    
    // MARK: - Repositories
    func makeProfileRepository() -> any UserProfileRepository {
        return DefaultUserProfileRepository()
    }
    
    func makeUUIDRepository() -> any UserUUIDRepository {
        return DefaultUserUUIDRepository()
    }
    
    func makeImageRepository() -> any ImageRepository {
        return DefaultImageRepository()
    }
    
    // MARK: - ViewModels
    func makeViewModel() -> any MyProfileViewModel {
        return DefaultMyProfileViewModel(profileLoadUseCase: self.makeMyProfileUseCase())
    }
    
    // MARK: - Create viewController
    func createMyProfileViewController() -> MyProfileViewController {
        return MyProfileViewController(coordinator: self.makeMyProfileCoordinator(), viewModel: self.makeViewModel())
    }
    
    // MARK: - Coordinator
    func makeMyProfileCoordinator() -> MyProfileCoordinator {
        return MyProfileCoordinator()
    }
}
