//
//  MyProfileDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/16.
//

import Foundation
import UIKit

final class DefaultMyProfileCoordinatorDependency: MyProfileCoordinatorDependency {
    func makeProfileSettingCoordinatorDependency(
        profile: UserProfile,
        necessaryProfileComponent: NecessaryProfileComponent?) -> ProfileSettingCoordinatorDependency {
            return DefaultProfileSettingDIContainer(
                dependency: .init(updateProfileUseCase: DefaultUpdateProfileUseCase(repository: self.profileRepository),
                                  validateNickNameUseCase: ValidateNickNameUseCase(),
                                  validateStatusMessageUseCase: ValidateStatusMessageUseCase(),
                                  uploadImageUseCase: DefaultUploadImageUseCase(imageRepository: self.imageRepository),
                                  profile: profile,
                                  necessaryProfileComponent: necessaryProfileComponent))
    }
    
    func makeMyProfileViewController(action: MyProfileViewModelAction) -> MyProfileViewController {
        let viewModel: MyProfileViewModel = DefaultMyProfileViewModel(
            profileRepository: self.profileRepository,
            imageRepository: self.imageRepository,
            action: action)
        return MyProfileViewController(viewModel: viewModel)
    }
    
    private let profileRepository: any ProfileRepository
    private let imageRepository: any ImageRepository
    
    init(profileRepository: any ProfileRepository,
         imageRepository: any ImageRepository) {
        self.profileRepository = profileRepository
        self.imageRepository = imageRepository
    }
}

final class MyProfileDIContainer {
    // MARK: - Dependencies
    struct Dependency {
        let fireStoreService: any FirestoreService
        let firebaseAuthService: any FirebaseAuthService
        let storageService: any StorageService
    }
    
    private let dependency: Dependency
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }

    // MARK: - UseCases
    
    // MARK: - Repositories
    func makeProfileRepository() -> any ProfileRepository {
        return DefaultProfileRepository(
            firestoreService: self.dependency.fireStoreService,
            firebaseAuthService: self.dependency.firebaseAuthService)
    }
    
    func makeImageRepository() -> any ImageRepository {
        return DefaultImageRepository(imageService: self.dependency.storageService)
    }
    
    // MARK: - DIContainers
    func makeCoordinatorDependency() -> any MyProfileCoordinatorDependency {
        return DefaultMyProfileCoordinatorDependency(
            profileRepository: self.makeProfileRepository(),
            imageRepository: self.makeImageRepository())
    }
}
