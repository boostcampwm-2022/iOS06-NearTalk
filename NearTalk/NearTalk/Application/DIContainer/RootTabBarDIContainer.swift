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
    func createTabBarController(dependency: RootTabBarControllerDependency) -> RootTabBarController {
        return RootTabBarController(viewModel: makeViewModel(), dependency: dependency)
    }
    
    // MARK: - Coordinator
    func makeTabBarCoordinator(navigationController: UINavigationController?) -> RootTabBarCoordinator? {
        let chatRoomListDIContainerDependency: ChatRoomListDIContainer.Dependencies = .init(
            apiDataTransferService: self.makeStorageService(),
            imageDataTransferService: self.makeStorageService()
        )
        let chatRoomListDIContainer: ChatRoomListDIContainer = .init(dependencies: chatRoomListDIContainerDependency)
        let chatRoomListCoordinator: ChatRoomListCoordinator = chatRoomListDIContainer.makeChatRoomListCoordinator(navigationController: .init())
        
        let friendListDIContainerDependencies: FriendListDIContainer.Dependencies = .init(
            firestoreService: self.makeFirestoreService(),
            firebaseAuthService: self.makeFirebaseAuthService()
        )
        let friendListDIContainer: FriendListDIContainer = .init(dependencies: friendListDIContainerDependencies)
        let friendListCoordinator: FriendListCoordinator = friendListDIContainer.makeFriendListCoordinator(navigationController: .init())
        
        let mainMapDIContainerDependencies: MainMapDIContainer.Dependencies = .init(
            firestoreService: self.makeFirestoreService(),
            apiDataTransferService: self.makeStorageService(),
            imageDataTransferService: self.makeStorageService()
        )
        let mainMapDIContainer: MainMapDIContainer = .init(dependencies: mainMapDIContainerDependencies)
        let mainMapCoordinator: MainMapCoordinator = mainMapDIContainer.makeMainMapCoordinator(navigationController: .init())
        
        let dependency: RootTabBarCoordinatorDependency = .init(
            mainMapCoordinator: mainMapCoordinator,
            chatRoomListCoordinator: chatRoomListCoordinator,
            friendListCoordinator: friendListCoordinator,
            myProfileCoordinator: MyProfileCoordinator(navigationController: .init())
        )
        return RootTabBarCoordinator(navigationController: navigationController, dependency: dependency)
    }
}
