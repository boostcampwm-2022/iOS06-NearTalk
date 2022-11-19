//
//  RootTabBarDIContainer.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import Foundation

final class RootTabBarDIContainer {
    // MARK: - Dependencies
    
    // MARK: - Services

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
    func createTabBarController() -> RootTabBarController {
        let chatRoomListRepository = DefaultChatRoomListRepository(dataTransferService: DefaultStorageService())
        let chatRoomListUseCase: ChatRoomListUseCase = DefaultChatRoomListUseCase(chatRoomListRepository: chatRoomListRepository)
        
        let myProfileDIContainer: MyProfileDIContainer = .init()
        let myProfileVC: MyProfileViewController = .init(coordinator: myProfileDIContainer.makeMyProfileCoordinator(), viewModel: myProfileDIContainer.makeViewModel())
        
        let dependency: RootTabBarControllerDependency = .init(
            mapViewController: MainMapViewController(),
            chatRoomListViewController: ChatRoomListViewController.create(with: DefaultChatRoomListViewModel(useCase: chatRoomListUseCase)),
            friendListViewController: FriendsListViewController(),
            myProfileViewController: myProfileVC
        )
        return RootTabBarController(viewModel: makeViewModel(), dependency: dependency)
    }
    
    // MARK: - Coordinator
    func makeTabBarCoordinator() -> RootTabBarCoordinator {
        return RootTabBarCoordinator()
    }
}