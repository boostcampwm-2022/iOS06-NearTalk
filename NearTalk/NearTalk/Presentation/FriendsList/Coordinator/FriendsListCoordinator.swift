//
//  FriendsListCoordinator.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation

import UIKit

protocol FriendLsitCoordinatorDependencies {
    
}

final class FriendListCoordinator {
    private weak var navigationController: UINavigationController?
    
//    private let dependencies: ChatRoomListCoordinatorDependencies

    private weak var friendListViewController: FriendsListViewController?
    
    // MARK: - Init
    init(navigationController: UINavigationController, dependencies: ChatRoomListCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycles
    func start() {
        // action


    }

    // MARK: - Dependency

    
}
