//
//  ChatRoomListCoordinator.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/11.
//

import UIKit

protocol ChatRoomListCoordinatorDependencies {
    func makeChatRoomListViewController(actions: ChatRoomListViewModelActions) -> ChatRoomListViewController
    func makeChatRoomViewController()
    func makeCreateChatRoomViewController()
    func makeChatDIContainer() -> ChatDIContainer
}

final class ChatRoomListCoordinator: Coordinator {
    weak var navigationController: UINavigationController?
    var parentCoordinator: Coordinator?
    private let dependencies: ChatRoomListCoordinatorDependencies

    private(set) weak var chatRoomListViewController: ChatRoomListViewController?
    
    // MARK: - Init
    init(navigationController: UINavigationController, dependencies: ChatRoomListCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycles
    func start() {
        let actions: ChatRoomListViewModelActions = .init(
            showChatRoom: self.showChatRoom,
            showCreateChatRoom: self.showCreateChatRoom,
            showDMChatRoomList: self.showDMChatRoomList,
            showGroupChatRoomList: self.showGroupChatRoomList
        )
        
        let viewController = dependencies.makeChatRoomListViewController(actions: actions)
        
        self.navigationController?.pushViewController(viewController, animated: false)
        self.chatRoomListViewController = viewController
    }
    
    // MARK: - Actions
    private func showDMChatRoomList() {
        guard let chatRoomListViewController = chatRoomListViewController
        else { return }
        
        chatRoomListViewController.dmCollectionView.isHidden = false
        chatRoomListViewController.groupCollectionView.isHidden = true
    }
    
    private func showGroupChatRoomList() {
        guard let chatRoomListViewController = chatRoomListViewController
        else { return }

        chatRoomListViewController.dmCollectionView.isHidden = true
        chatRoomListViewController.groupCollectionView.isHidden = false
    }

    private func showChatRoom() {
        guard let navigationController = navigationController
        else { return }
        
        let diContainer = dependencies.makeChatDIContainer()
        let coordinator = diContainer.makeChatCoordinator(navigationController: navigationController)
        coordinator.start()
    }
    
    private func showCreateChatRoom() {
        // let viewController = dependencies.makeCreateChatRoomViewController(actions: )
        // navigationController?.pushViewController(viewController, animated: true)
    }
    
}
