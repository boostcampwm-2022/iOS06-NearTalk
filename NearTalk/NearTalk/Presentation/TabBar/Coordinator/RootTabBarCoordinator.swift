//
//  RootTabBarCoordinator.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import UIKit

protocol RootTabBarCoordinatorDependency {
    func makeRootTabBarViewController() -> RootTabBarController
    func mainMapCoordinator() -> MainMapCoordinator
    func chatRoomListDIConatiner() -> ChatRoomListDIContainer
    func friendListDIConatiner() -> FriendListDIContainer
    func myProfileDIConatiner() -> MyProfileDIContainer
}

final class RootTabBarCoordinator {
    var navigationController: UINavigationController?
    var tabbarViewController: UITabBarController?
    var dependency: RootTabBarCoordinatorDependency
    
    init(navigationController: UINavigationController?, dependency: RootTabBarCoordinatorDependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    } 
    
    func start() {
        let viewcontroller: RootTabBarController = dependency.makeRootTabBarViewController()
        self.tabbarViewController = viewcontroller
        
        guard let tabbarViewController = self.tabbarViewController
        else { return }
        
        tabbarViewController.viewControllers = [showMapView(), showChatRoomList(), showFriendList(), showMyProfile()]
        tabbarViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(tabbarViewController, animated: true)
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
        let navigationController = UINavigationController()
        let diContainer = dependency.chatRoomListDIConatiner()
        let coordinator = diContainer.makeChatRoomListCoordinator(navigationController: navigationController)
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
        let diContainer = dependency.friendListDIConatiner()
        let coordinator = diContainer.makeFriendListCoordinator(navigationController: navigationController)
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
