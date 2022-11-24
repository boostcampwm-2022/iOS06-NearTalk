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
    var parentCoordinator: Coordinator?
    
    private var mainMapCoordinator: MainMapCoordinator?
    private var chatRoomListCoordinator: ChatRoomListCoordinator?
    private var friendListCoordinator: FriendListCoordinator?
    private var myProfileCoordinator: MyProfileCoordinator?
    
    init(navigationController: UINavigationController?, dependency: RootTabBarCoordinatorDependency) {
        self.navigationController = navigationController
        self.mainMapCoordinator = dependency.mainMapCoordinator
        self.chatRoomListCoordinator = dependency.chatRoomListCoordinator
        self.friendListCoordinator = dependency.friendListCoordinator
        self.myProfileCoordinator = dependency.myProfileCoordinator
        
        self.assignParentCoordinator()
    }
    
    func start() {
        let viewcontroller: RootTabBarController = RootTabBarDIContainer().createTabBarController(dependency: makeDependency())
        self.navigationController?.viewControllers.insert(viewcontroller, at: 0)
        self.navigationController?.popToRootViewController(animated: false)
    }
    
#warning("myProfileViewController DI Container 필요")
    private func makeDependency() -> RootTabBarControllerDependency {
        self.myProfileCoordinator?.start()
        return .init(
            mainMapNavigationController: .init(),
            chatRoomListNavigationController: .init(),
            friendListNavigationController: .init(),
            myProfileNavigationController: self.myProfileCoordinator?.navigationController ?? .init()
        )
    }
    
    private func assignParentCoordinator() {
        self.mainMapCoordinator?.parentCoordinator = self
        self.chatRoomListCoordinator?.parentCoordinator = self
        self.friendListCoordinator?.parentCoordinator = self
        self.myProfileCoordinator?.parentCoordinator = self
    }
}
