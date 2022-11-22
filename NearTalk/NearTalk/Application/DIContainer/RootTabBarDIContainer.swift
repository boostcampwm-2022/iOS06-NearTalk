//
//  RootTabBarDIContainer.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import Foundation
import UIKit

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
    
#warning("mapViewController DI Container 필요")
#warning("chatRoomListViewController DI Container 필요")
#warning("friendListViewController DI Container 필요")
#warning("myProfileViewController DI Container 필요")
    // MARK: - Create viewController
    func createTabBarController() -> RootTabBarController {
        let chatRoomListRepository = DefaultChatRoomListRepository(dataTransferService: DefaultStorageService())
        let chatRoomListUseCase: FetchChatRoomUseCase = DefaultFetchChatRoomUseCase(chatRoomListRepository: chatRoomListRepository)
        
        let myProfileDIContainer: MyProfileDIContainer = .init()
        let myProfileVC: MyProfileViewController = .init(coordinator: myProfileDIContainer.makeMyProfileCoordinator(), viewModel: myProfileDIContainer.makeViewModel())
        
        let dependency: RootTabBarControllerDependency = .init(
            mapViewController: MainMapViewController(),
            chatRoomListViewController: ChatRoomListViewController.create(with: DefaultChatRoomListViewModel(useCase: chatRoomListUseCase)),
            friendListViewController: FriendListViewController(),
            myProfileViewController: myProfileVC
        )
        return RootTabBarController(viewModel: makeViewModel(), dependency: dependency)
    }
    
    // MARK: - Coordinator
    func makeTabBarCoordinator(navigationController: UINavigationController?) -> RootTabBarCoordinator {
        return RootTabBarCoordinator(navigationController: navigationController)
    }
}
