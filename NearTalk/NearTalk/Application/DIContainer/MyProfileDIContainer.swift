//
//  MyProfileDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/16.
//

import Foundation
import UIKit

final class DefaultMyProfileCoordinatorDependency: MyProfileCoordinatorDependency {
    private let profileRepository: any ProfileRepository
    private let mediaRepository: any MediaRepository
    
    init(
        profileRepository: any ProfileRepository,
        mediaRepository: any MediaRepository
    ) {
        self.profileRepository = profileRepository
        self.mediaRepository = mediaRepository
    }
    
    func makeProfileSettingCoordinatorDependency(
        profile: UserProfile,
        necessaryProfileComponent: NecessaryProfileComponent?) -> ProfileSettingCoordinatorDependency {
            return DefaultProfileSettingDIContainer(
                dependency: .init(
                    updateProfileUseCase: DefaultUpdateProfileUseCase(repository: self.profileRepository),
                    validateNickNameUseCase: ValidateNickNameUseCase(),
                    validateStatusMessageUseCase: ValidateStatusMessageUseCase(),
                    uploadImageUseCase: DefaultUploadImageUseCase(mediaRepository: self.mediaRepository),
                    profile: profile,
                    necessaryProfileComponent: necessaryProfileComponent)
            )
        }
    
    func makeMyProfileViewController(action: MyProfileViewModelAction) -> MyProfileViewController {
        let viewModel: MyProfileViewModel = DefaultMyProfileViewModel(
            profileRepository: self.profileRepository,
            mediaRepository: self.mediaRepository,
            action: action
        )
        return MyProfileViewController(viewModel: viewModel)
    }
}

final class MyProfileDIContainer {
    // MARK: - Service
    func makeImageService() -> any StorageService {
        return DefaultStorageService()
    }
    
    func makeAuthService() -> any AuthService {
        return DefaultFirebaseAuthService()
    }
    
    func makeFirestoreService() -> any FirestoreService {
        return DefaultFirestoreService()
    }
    
    // MARK: - Repositories
    func makeProfileRepository() -> any ProfileRepository {
        return DefaultProfileRepository(firestoreService: self.makeFirestoreService(), firebaseAuthService: self.makeAuthService())
    }
    
    func makeMediaRepository() -> any MediaRepository {
        return DefaultMediaRepository(storageService: self.makeImageService())
    }
    
    func makeAuthRepository() -> any AuthRepository {
        return DefaultAuthRepository(authService: self.makeAuthService())
    }
    
    // MARK: - Coordinator
    func makeCoordinator(
        navigationController: UINavigationController?,
        parent: Coordinator
    ) -> MyProfileCoordinator {
        return MyProfileCoordinator(
            navigationController: navigationController,
            parentCoordinator: parent,
            childCoordinators: [],
            dependency: makeCoordinatorDependency()
        )
    }
    
    // MARK: - DIContainers
    func makeCoordinatorDependency() -> any MyProfileCoordinatorDependency {
        return DefaultMyProfileCoordinatorDependency(
            profileRepository: self.makeProfileRepository(),
            mediaRepository: self.makeMediaRepository()
        )
    }
}
