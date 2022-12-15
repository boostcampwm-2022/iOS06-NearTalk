//
//  ProfileDetailCoordinator.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/17.
//

import UIKit

protocol ProfileDetailCoordinatorDependency {
    func makeProfileDetailViewController(actions: ProfileDetailViewModelActions) -> ProfileDetailViewController
    func makeChatDIContainer(chatRoomID: String) -> ChatDIContainer
}

final class ProfileDetailCoordinator {
    var navigationController: UINavigationController?
    private let dependencies: ProfileDetailCoordinatorDependency
    
    init(navigationController: UINavigationController,
         dependency: ProfileDetailCoordinatorDependency) {
        self.navigationController = navigationController
        self.dependencies = dependency
    }
    
    func start() {
        let actions = ProfileDetailViewModelActions(
            showChatViewController: self.showChatViewController,
            dismissProfileDetailController: self.dismissProfileDetailController
        )
        
        let viewController: ProfileDetailViewController = self.dependencies.makeProfileDetailViewController(actions: actions)
        self.navigationController?.present(viewController, animated: true)
    }
    
    func showChatViewController(chatRoomID: String) {
        print(#function)
        guard let navigationController = self.navigationController
        else {
            return
        }
        
        let diContainer = self.dependencies.makeChatDIContainer(chatRoomID: chatRoomID)
        let coordinator = diContainer.makeChatCoordinator(navigationController: navigationController)
        navigationController.dismiss(animated: true)
        coordinator.start()
    }
    
    func dismissProfileDetailController() {
        guard let navigationController = self.navigationController
        else {
            return
        }
        navigationController.dismiss(animated: true)
    }
}
