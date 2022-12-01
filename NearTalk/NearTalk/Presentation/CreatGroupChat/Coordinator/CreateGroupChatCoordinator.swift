//
//  CreateGroupChatCoordinator.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/17.
//

import UIKit

protocol CreateGroupChatCoordinatorDependencies {
    func makeCreateGroupChatViewController(actions: CreateGroupChatViewModelActions) -> CreateGroupChatViewController
    func makeChatDIContainer(chatRoomID: String) -> ChatDIContainer
}

final class CreateGroupChatCoordinator {
    // MARK: - Proporties
    
    weak var navigationController: UINavigationController?
    var parentCoordinator: Coordinator?
    private let dependencies: CreateGroupChatCoordinatorDependencies
    private(set) weak var createGroupChatViewController: CreateGroupChatViewController?
    
    init(navigationController: UINavigationController, dependencies: CreateGroupChatCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycles
    func start() {
        let actions: CreateGroupChatViewModelActions = .init(showChatViewController: showChatViewController)
        let viewController = dependencies.makeCreateGroupChatViewController(actions: actions)
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
        self.createGroupChatViewController = viewController
    }

    func showChatViewController(chatRoomID: String) {
        print(#function)
        guard let navigationController = navigationController
        else { return }
        
        let dicontainer = self.dependencies.makeChatDIContainer(chatRoomID: chatRoomID)
        let coordinator = dicontainer.makeChatCoordinator(navigationController: navigationController)
        coordinator.start()
    }
}
