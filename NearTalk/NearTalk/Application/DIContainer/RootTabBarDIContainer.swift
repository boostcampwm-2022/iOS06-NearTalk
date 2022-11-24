//
//  RootTabBarDIContainer.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import UIKit

final class RootTabBarDIContainer {
    // MARK: - Dependencies
    // MARK: - Services
    func makeStorageService() -> StorageService {
        return DefaultStorageService()
    }
    
    func makeFirebaseAuthService() -> AuthService {
        return DefaultFirebaseAuthService()
    } 
    
    func makeFirestoreService() -> FirestoreService {
        return DefaultFirestoreService()
    }

    // MARK: - UseCases
    func makeTabBarUseCase() -> TabBarUseCase {
        return DefaultTabBarUseCase()
    }
    
    // MARK: - Repositories
    func makeRepository() -> TabBarRepository {
        return DefaultTabBarRepository()
    }
    
    // MARK: - ViewModels
    func makeViewModel() -> RootTabBarViewModel {
        return DefaultRootTabBarViewModel()
    }

    // MARK: - Create viewController
    func makeRootTabBarViewController() -> RootTabBarController {
        return RootTabBarController.create(with: makeViewModel())
    }
    
    // MARK: - Coordinator
    func makeTabBarCoordinator(navigationController: UINavigationController?) -> RootTabBarCoordinator? {
        return RootTabBarCoordinator(navigationController: navigationController, dependency: self)
    }
}

extension RootTabBarDIContainer: RootTabBarCoordinatorDependency {
    func mainMapCoordinator() -> MainMapCoordinator {
        return MainMapCoordinator()
    }
    
    func chatRoomListDIConatiner() -> ChatRoomListDIContainer {
        return ChatRoomListDIContainer()
    }
    
    func friendListDIConatiner() -> FriendListDIContainer {
        return FriendListDIContainer()
    }
    
    func myProfileDIConatiner() -> MyProfileDIContainer {
        return MyProfileDIContainer()
    }
}
