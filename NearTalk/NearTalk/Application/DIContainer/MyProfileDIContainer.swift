//
//  MyProfileDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/16.
//

import Foundation
import UIKit

final class DefaultMyProfileCoordinatorDependency: MyProfileCoordinatorDependency {
    func makeAppSettingCoordinatorDependency() -> AppSettingCoordinatorDependency {
        return DefaultAppSettingDIContainer(dependency: .init(
            authRepository: self.authRepository,
            profileRepository: self.profileRepository,
            userDefaultsRepository: self.userDefaultsRepository,
            chatRoomListRepository: self.chatRoomListRepository,
            backToLoginView: self.backToLoginView))
    }
    
    private let profileRepository: any ProfileRepository
    private let mediaRepository: any MediaRepository
    private let authRepository: any AuthRepository
    private let chatRoomListRepository: any ChatRoomListRepository
    private let backToLoginView: (() -> Void)?
    private let userDefaultsRepository: any UserDefaultsRepository
    
    init(
        profileRepository: any ProfileRepository,
        mediaRepository: any MediaRepository,
        userDefaultsRepository: any UserDefaultsRepository,
        authRepository: any AuthRepository,
        chatRoomListRepository: any ChatRoomListRepository,
        backToLoginView: (() -> Void)?
    ) {
        self.profileRepository = profileRepository
        self.mediaRepository = mediaRepository
        self.userDefaultsRepository = userDefaultsRepository
        self.authRepository = authRepository
        self.chatRoomListRepository = chatRoomListRepository
        self.backToLoginView = backToLoginView
    }
    
    func makeProfileSettingCoordinatorDependency(
        profile: UserProfile,
        necessaryProfileComponent: NecessaryProfileComponent?) -> ProfileSettingCoordinatorDependency {
            return DefaultProfileSettingDIContainer(
                dependency: .init(
                    updateProfileUseCase: DefaultUpdateProfileUseCase(
                        repository: self.profileRepository,
                        userDefaultsRepository: self.userDefaultsRepository
                    ),
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
    
    func makeUserDefaultsRepository() -> any UserDefaultsRepository {
        return DefaultUserDefaultsRepository(userDefaultsService: DefaultUserDefaultsService())
    }
    
    func makeChatRoomListRepository() -> any ChatRoomListRepository {
        return DefaultChatRoomListRepository(
            dataTransferService: DefaultStorageService(),
            profileRepository: DefaultProfileRepository(
                firestoreService: self.makeFirestoreService(),
                firebaseAuthService: self.makeAuthService()),
            databaseService: DefaultRealTimeDatabaseService(),
            firestoreService: self.makeFirestoreService())
    }
    
    // MARK: - Coordinator
    func makeCoordinator(
        navigationController: UINavigationController?,
        parent: Coordinator,
        backToLoginView: (() -> Void)? = nil
    ) -> MyProfileCoordinator {
        return MyProfileCoordinator(
            navigationController: navigationController,
            parentCoordinator: parent,
            childCoordinators: [],
            dependency: makeCoordinatorDependency(backToLoginView)
        )
    }
    
    // MARK: - DIContainers
    func makeCoordinatorDependency(_ backToLoginView: (() -> Void)?) -> any MyProfileCoordinatorDependency {
        return DefaultMyProfileCoordinatorDependency(
            profileRepository: self.makeProfileRepository(),
            mediaRepository: self.makeMediaRepository(),
            userDefaultsRepository: self.makeUserDefaultsRepository(),
            authRepository: self.makeAuthRepository(),
            chatRoomListRepository: self.makeChatRoomListRepository(),
            backToLoginView: backToLoginView
        )
    }
}
