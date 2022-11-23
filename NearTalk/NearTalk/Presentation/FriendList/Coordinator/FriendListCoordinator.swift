//
//  FriendsListCoordinator.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation

import UIKit

protocol FriendListCoordinatorDependencies {
    func makeFriendListViewController(actions: FriendListViewModelActions) -> FriendListViewController
//    func makeProfileDetailViewController()
}

final class FriendListCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    weak var navigationController: UINavigationController?
    private let dependencies: FriendListCoordinatorDependencies

    private weak var friendListViewController: FriendListViewController?
    
    // MARK: - Init
    init(navigationController: UINavigationController, dependencies: FriendListCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycles
    func start() {
        let actions: FriendListViewModelActions = .init(showDetailFriend: self.showDetailFriend)
        let viewController = dependencies.makeFriendListViewController(actions: actions)
        
        self.navigationController?.pushViewController(viewController, animated: false)
        self.friendListViewController = viewController

    }

    // MARK: - Dependency
    private func showDetailFriend() {
//         let viewController = dependencies.makeProfileDetailViewController(actions: actions)
//         navigationController?.pushViewController(viewController, animated: true)
    }
    
}
