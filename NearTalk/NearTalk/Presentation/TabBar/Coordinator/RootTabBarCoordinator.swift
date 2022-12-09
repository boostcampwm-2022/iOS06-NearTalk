//
//  RootTabBarCoordinator.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import UIKit

struct RootTabBarCoordinatorDependency {
    let mainMapCoordinator: MainMapCoordinator
    let chatRoomListCoordinator: ChatRoomListCoordinator
    let friendListCoordinator: FriendListCoordinator
    let myProfileCoordinator: MyProfileCoordinator
}

final class RootTabBarCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var tabBarViewController: UITabBarController?
    private let rootTabBarDIContainer: RootTabBarDIContainer

    init(
        navigationController: UINavigationController?,
        container: RootTabBarDIContainer
    ) {
        self.navigationController = navigationController
        self.rootTabBarDIContainer = container
    } 
    
    func start() {
        let viewcontroller: RootTabBarController = rootTabBarDIContainer.resolveRootTabBarViewController()
        self.tabBarViewController = viewcontroller
        viewcontroller.viewControllers = [showMapView(), showChatRoomList(), showFriendList(), showMyProfile()]
        self.navigationController?.pushViewController(viewcontroller, animated: false)
        self.navigationController?.navigationBar.isHidden = true
    }
        
    private func showMapView() -> UIViewController {
        let navigationController: UINavigationController = .init()
        let diContainer: MainMapDIContainer = .init()
        let coordinator: MainMapCoordinator = diContainer.makeMainMapCoordinator(navigationController: navigationController)
        coordinator.start()
        return self.embed(
            rootNav: navigationController,
            title: "홈",
            inactivatedImage: UIImage(systemName: "house")?.withTintColor(.label!),
            activatedImage: UIImage(systemName: "house.fill")?.withTintColor(.label!)
        )
    }
    
    private func showChatRoomList() -> UIViewController {
        let navigationController: UINavigationController = .init()
        let diContainer: ChatRoomListDIContainer = .init()
        let coordinator: ChatRoomListCoordinator = diContainer.makeChatRoomListCoordinator(navigationController: navigationController)
        coordinator.start()
        return self.embed(
            rootNav: navigationController,
            title: "채팅",
            inactivatedImage: UIImage(systemName: "message")?.withTintColor(.label!),
            activatedImage: UIImage(systemName: "message.fill")?.withTintColor(.label!)
        )
    }

    private func showFriendList() -> UIViewController {
        let navigationController: UINavigationController = .init()
        let diContainer: FriendListDIContainer = .init()
        let coordinator: FriendListCoordinator = diContainer.makeFriendListCoordinator(navigationController: navigationController)
        coordinator.start()
        
        return self.embed(
            rootNav: navigationController,
            title: "친구",
            inactivatedImage: UIImage(systemName: "person.3")?.withTintColor(.label!),
            activatedImage: UIImage(systemName: "person.3.fill")?.withTintColor(.label!)
        )
    }

    private func showMyProfile() -> UIViewController {
        let navigationController = UINavigationController()
        let diContainer: MyProfileDIContainer = .init()
        let coordinator: MyProfileCoordinator = diContainer.makeCoordinator(
            navigationController: navigationController,
            parent: self,
            backToLoginView: self.rootTabBarDIContainer.resolveBackToLoginView()
        )
        coordinator.start()
        
        return self.embed(
            rootNav: navigationController,
            title: "마이페이지",
            inactivatedImage: UIImage(systemName: "person")?.withTintColor(.label!),
            activatedImage: UIImage(systemName: "person.fill")?.withTintColor(.label!)
        )
    }
    
    private func embed(
        rootNav: UINavigationController,
        title: String?,
        inactivatedImage: UIImage?,
        activatedImage: UIImage?
    ) -> UIViewController {
        let tabBarItem = UITabBarItem(
            title: title,
            image: inactivatedImage?.withRenderingMode(.alwaysOriginal),
            selectedImage: activatedImage?.withRenderingMode(.alwaysOriginal)
        )
        rootNav.tabBarItem = tabBarItem
        return rootNav
    }
}
