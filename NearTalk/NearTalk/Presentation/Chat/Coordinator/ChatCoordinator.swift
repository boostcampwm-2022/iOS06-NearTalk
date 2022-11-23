//
//  ChatCoordinator.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

protocol ChatCoordinatorDependencies {
    func makeChatViewController() -> ChatViewController
}

final class ChatCoordinator {
    weak var navigationController: UINavigationController?
    private let dependencies: ChatCoordinatorDependencies

    private weak var chatViewController: ChatViewController?
    
    // MARK: - Init
    init(navigationController: UINavigationController, dependencies: ChatCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycles
    func start() {
        let viewController = dependencies.makeChatViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
        self.chatViewController = viewController
    }

    // MARK: - Dependency
}
