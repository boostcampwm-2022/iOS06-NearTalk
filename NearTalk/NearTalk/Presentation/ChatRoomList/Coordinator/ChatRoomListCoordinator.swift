//
//  ChatRoomListCoordinator.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/11.
//

import UIKit

protocol ChatRoomListCoordinatorDependency {
    func showChatRoomViewController()
    func showCreateChatRoomViewController()
}

class ChatRoomListCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private let diContainer: ChatRoomListDIContainer = .init()
    private let dependency: any ChatRoomListCoordinatorDependency
    private var chatRoomListViewController: ChatRoomListViewController?
    
    // MARK: - Init
    init(
        navigationController: UINavigationController? = nil, parentCoordinator: Coordinator? = nil, dependency: ChatRoomListCoordinatorDependency) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependency = dependency
    }
    
    // MARK: - Lifecycles
    func start() {
        let actions: ChatRoomListViewModelActions = .init(
            showChatRoom: self.showChatRoomViewController,
            showCreateChatRoom: self.showCreateChatRoomViewController
        )
        
        let coordinator: ChatRoomListCoordinator =
        self.diContainer.makeChatRoomListCoordinator(navigationController: self.navigationController, dependency: dependency)
        
        let viewController: ChatRoomListViewController = self.diContainer.createChatRoomListViewController(actions: actions, coordinator: coordinator)
        
        self.chatRoomListViewController = viewController
        self.navigationController?.pushViewController(viewController, animated: false)

    }
    
    func close() {
        self.navigationController?.popViewController(animated: false)
        self.chatRoomListViewController = nil
    }
    
    // MARK: - Dependency
    private func showChatRoomViewController() {
        self.dependency.showChatRoomViewController()
    }
    
    private func showCreateChatRoomViewController() {
        self.dependency.showCreateChatRoomViewController()
    }
    
}
