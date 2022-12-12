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
    
    private enum TabItems {
        case mapView
        case chatRoomList
        case friendList
        case myProfile
        
        var title: String {
            switch self {
            case .mapView:
                return "지도"
            case .chatRoomList:
                return "채팅"
            case .friendList:
                return "친구"
            case .myProfile:
                return "마이프로필"
            }
        }
        
        var inactivatedImage: UIImage? {
            guard let color: UIColor = .label
            else { return nil }
            
            switch self {
            case .mapView:
                return UIImage(systemName: "map")?.withTintColor(color)
            case .chatRoomList:
                return UIImage(systemName: "message")?.withTintColor(color)
            case .friendList:
                return UIImage(systemName: "person.3")?.withTintColor(color)
            case .myProfile:
                return UIImage(systemName: "person")?.withTintColor(color)
            }
        }
        
        var activatedImage: UIImage? {
            guard let color: UIColor = .label
            else { return nil }
            
            switch self {
            case .mapView:
                return UIImage(systemName: "map.fill")?.withTintColor(color)
            case .chatRoomList:
                return UIImage(systemName: "message.fill")?.withTintColor(color)
            case .friendList:
                return UIImage(systemName: "person.3.fill")?.withTintColor(color)
            case .myProfile:
                return UIImage(systemName: "person.fill")?.withTintColor(color)
            }
        }
    }
    
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
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.viewControllers.insert(viewcontroller, at: 0)
        self.navigationController?.popToRootViewController(animated: false)
    }
        
    private func showMapView() -> UIViewController {
        let navigationController: UINavigationController = .init()
        let diContainer: MainMapDIContainer = .init()
        let coordinator: MainMapCoordinator = diContainer.makeMainMapCoordinator(navigationController: navigationController)
        coordinator.start()
        return self.embed(
            rootNav: navigationController,
            title: TabItems.mapView.title,
            inactivatedImage: TabItems.mapView.inactivatedImage,
            activatedImage: TabItems.mapView.activatedImage
        )
    }
    
    private func showChatRoomList() -> UIViewController {
        let navigationController: UINavigationController = .init()
        let diContainer: ChatRoomListDIContainer = .init()
        let coordinator: ChatRoomListCoordinator = diContainer.makeChatRoomListCoordinator(navigationController: navigationController)
        coordinator.start()
        return self.embed(
            rootNav: navigationController,
            title: TabItems.chatRoomList.title,
            inactivatedImage: TabItems.chatRoomList.inactivatedImage,
            activatedImage: TabItems.chatRoomList.activatedImage
        )
    }

    private func showFriendList() -> UIViewController {
        let navigationController: UINavigationController = .init()
        let diContainer: FriendListDIContainer = .init()
        let coordinator: FriendListCoordinator = diContainer.makeFriendListCoordinator(navigationController: navigationController)
        coordinator.start()
        
        return self.embed(
            rootNav: navigationController,
            title: TabItems.friendList.title,
            inactivatedImage: TabItems.friendList.inactivatedImage,
            activatedImage: TabItems.friendList.activatedImage
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
            title: TabItems.myProfile.title,
            inactivatedImage: TabItems.myProfile.inactivatedImage,
            activatedImage: TabItems.myProfile.activatedImage
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
