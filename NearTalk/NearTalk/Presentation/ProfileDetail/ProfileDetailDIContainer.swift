//
//  ProfileDetailDIContainer.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/22.
//

import UIKit

protocol ProfileDetailCoordinatorDependency {
    func makeProfileDetailViewController(actions: ProfileDetailViewModelActions) -> ProfileDetailViewController
}

final class ProfileDetailDIContainer {
    // MARK: - Dependencies
    
    // MARK: - Services
    func makeFirestoreService() -> FirestoreService {
        return DefaultFirestoreService()
    }
    
    func makefirebaseAuthService() -> FirebaseAuthService {
        return DefaultFirebaseAuthService()
    }
    
    // MARK: - UseCases
    func makeFetchProfileUseCase() -> FetchProfileUseCase {
        return DefaultFetchProfileUseCase(profileRepository: self.makeProfileDetailRepository())
    }
    
    func makeUploadChatRoomInfoUseCase() -> UploadChatRoomInfoUseCase {
        return DefaultUploadChatRoomInfoUseCase()
    }
    
    func makeRemoveFriendUseCase() -> RemoveFriendUseCase {
        return DefaultRemoveFriendUseCase(profileRepository: self.makeProfileDetailRepository())
    }
    
    // MARK: - Repositories
    func makeProfileDetailRepository() -> ProfileRepository {
        return DefaultProfileRepository(
            firestoreService: self.makeFirestoreService(),
            firebaseAuthService: self.makefirebaseAuthService())
    }
    
    // MARK: - ViewModels
    func makeProfileDetailViewModel(
        userID: String,
        actions: ProfileDetailViewModelActions
    ) -> any ProfileDetailViewModelable {
        
        return ProfileDetailViewModel(
            userID: userID,
            fetchProfileUseCase: self.makeFetchProfileUseCase(),
            uploadChatRoomInfoUseCase: self.makeUploadChatRoomInfoUseCase(),
            removeFriendUseCase: self.makeRemoveFriendUseCase(),
            actions: actions)
    }
    
    // MARK: - Create viewController
    func createProfileDetailViewController(
        userID: String,
        actions: ProfileDetailViewModelActions
    ) -> ProfileDetailViewController {
        return ProfileDetailViewController.create(with: self.makeProfileDetailViewModel(
            userID: userID,
            actions: actions
        ))
    }
    
    // MARK: - Coordinator
    func makeProfileDetailCoordinator(
        navigationController: UINavigationController,
        dependency: ProfileDetailCoordinatorDependency
    ) -> ProfileDetailCoordinator {
        return ProfileDetailCoordinator(
            navigationController: navigationController,
            dependency: dependency)
    }
}
