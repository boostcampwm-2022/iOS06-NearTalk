//
//  CreateGroupChatCoordinator.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/17.
//

import UIKit

final class CreateGroupChatCoordinator: CreateGroupChatCoordinatable {
    // MARK: - Proporties
    
    var navigationController: UINavigationController?
    
    var parentCoordinator: Coordinator?
    
    var childCoordinators: [Coordinator]
    
    func start() {
        print(#function)
    }
    
    init(navigationController: UINavigationController? = nil, parentCoordinator: Coordinator? = nil, childCoordinators: [Coordinator]) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.childCoordinators = childCoordinators
    }
    
    func showChatViewController() {
        print(#function)
    }
}
