//
//  RootTabBarCoordinator.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import UIKit

final class RootTabBarCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var tabBarViewController: UITabBarController?
    var parentCoordinator: Coordinator?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    } 
    
    func start() {
        let diContainer: RootTabBarDIContainer = .init()
        let viewcontroller: RootTabBarController = diContainer.makeRootTabBarViewController()
        self.tabBarViewController = viewcontroller
        viewcontroller.viewControllers = [showMapView(), showChatRoomList(), showFriendList(), showMyProfile()]
        self.navigationController?.viewControllers.insert(viewcontroller, at: 0)
        self.navigationController?.popViewController(animated: false)
        self.navigationController?.navigationBar.isHidden = true
    }
        
    private func showMapView() -> UIViewController {
        let navigationController = UINavigationController()
        return self.embed(
            rootNav: navigationController,
            title: "홈",
            inactivatedImage: UIImage(systemName: "house")?.withTintColor(.darkGray),
            activatedImage: UIImage(systemName: "house.fill")?.withTintColor(.blue)
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
            inactivatedImage: UIImage(systemName: "message")?.withTintColor(.darkGray),
            activatedImage: UIImage(systemName: "message.fill")?.withTintColor(.blue)
        )
    }

    private func showFriendList() -> UIViewController {
        let navigationController = UINavigationController()
        let diContainer: FriendListDIContainer = .init()
        let coordinator: FriendListCoordinator = diContainer.makeFriendListCoordinator(navigationController: navigationController)
        coordinator.start()
        return self.embed(
            rootNav: navigationController,
            title: "친구",
            inactivatedImage: UIImage(systemName: "figure.2.arms.open")?.withTintColor(.darkGray),
            activatedImage: UIImage(systemName: "figure.2.arms.open")?.withTintColor(.blue)
        )
    }

    private func showMyProfile() -> UIViewController {
        let navigationController = UINavigationController()
        let diContainer: MyProfileDIContainer = .init()
        let coordinator: MyProfileCoordinator = diContainer.makeCoordinator(
            navigationController: navigationController,
            parent: self
        )
        coordinator.start()
        return self.embed(
            rootNav: navigationController,
            title: "마이페이지",
            inactivatedImage: UIImage(systemName: "figure.wave")?.withTintColor(.darkGray),
            activatedImage: UIImage(systemName: "figure.wave")?.withTintColor(.blue)
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
