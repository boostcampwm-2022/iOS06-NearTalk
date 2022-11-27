//
//  FriendListDIContainer.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/21.
//

import UIKit

final class FriendListDIContainer {
    
    // MARK: - Dependencies
    
    // MARK: - Persistent Storage
    
    // MARK: - Services
    
    private let firestoreService: FirestoreService = DefaultFirestoreService()
    private let firebaseAuthService: AuthService = DefaultFirebaseAuthService()
    private let imageService: StorageService = DefaultStorageService()
    
    // MARK: - UseCases
    func makeFetchFriendListUseCase() -> FetchFriendListUseCase {
        return DefaultFetchFriendListUseCase(profileRepository: self.makeRepository())
    }
    
    func makeImageUseCase() -> ImageUseCase {
        return DefaultImageUseCase(imageRepository: makeImageRepository())
    }
    
    // MARK: - Repositories
    func makeRepository() -> ProfileRepository {
        return DefaultProfileRepository(firestoreService: firestoreService, firebaseAuthService: firebaseAuthService)
    }
    
    func makeImageRepository() -> ImageRepository {
        return DefaultImageRepository(imageService: imageService)
    }
    
    // MARK: - Friend Lsit
    func makeFriendListViewController(actions: FriendListViewModelActions) -> FriendListViewController {
        return FriendListViewController.create(with: self.makeFriendListViewModel(actions: actions))
    }
    
    func makeFriendListViewModel(actions: FriendListViewModelActions) -> FriendListViewModel {
        return DefaultFriendListViewModel(fetchFriendListUseCase: makeFetchFriendListUseCase(), imageUseCase: makeImageUseCase())
    }
    
    // MARK: - Coordinator
    func makeFriendListCoordinator(navigationController: UINavigationController) -> FriendListCoordinator {
        return FriendListCoordinator(navigationController: navigationController, dependencies: self)
    }
    
    // MARK: - DI Container
    func makeProfileDetailDIContainer(userID: String) -> ProfileDetailDIContainer {
        return ProfileDetailDIContainer(userID: userID)
    }
}

extension FriendListDIContainer: FriendListCoordinatorDependencies { }
