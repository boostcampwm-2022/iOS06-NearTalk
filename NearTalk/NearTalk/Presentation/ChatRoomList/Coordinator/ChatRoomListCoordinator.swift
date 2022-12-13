//
//  ChatRoomListCoordinator.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/11.
//

import UIKit

protocol ChatRoomListCoordinatorDependencies {
    func makeChatRoomListViewController(actions: ChatRoomListViewModelActions) -> ChatRoomListViewController
    func makeChatDIContainer(chatRoomID: String) -> ChatDIContainer
    func makeCreateGroupChatDIContainer() -> CreateGroupChatDIContainer
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
            showGroupChatRoomList: self.showGroupChatRoomList,
            showAlert: self.showAlert
        )
        
        let viewController = dependencies.makeChatRoomListViewController(actions: actions)
        
        self.navigationController?.pushViewController(viewController, animated: false)
        self.chatRoomListViewController = viewController
    }
    
    // MARK: - Actions
    private func showDMChatRoomList() {
        guard let chatRoomListViewController = chatRoomListViewController
        else {
            return
        }
        
        chatRoomListViewController.dmCollectionView.isHidden = false
        chatRoomListViewController.groupCollectionView.isHidden = true
    }
    
    private func showGroupChatRoomList() {
        guard let chatRoomListViewController = chatRoomListViewController
        else {
            return
        }
        
        chatRoomListViewController.dmCollectionView.isHidden = true
        chatRoomListViewController.groupCollectionView.isHidden = false
    }
    
    private func showChatRoom(chatRoomID: String) {
        guard let navigationController = navigationController
        else {
            return
        }
        
        let diContainer = dependencies.makeChatDIContainer(chatRoomID: chatRoomID)
        let coordinator = diContainer.makeChatCoordinator(navigationController: navigationController)
        coordinator.start()
    }
    
    private func showCreateChatRoom() {
        guard let navigationController = navigationController
        else {
            return
        }
        
        let diContainer = dependencies.makeCreateGroupChatDIContainer()
        let coordinator = diContainer.makeCreateGroupChatCoordinator(navigationCotroller: navigationController)
        coordinator.start()
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "채팅방 입장 불가", message: "채팅방 입장가능 범위 밖입니다.", preferredStyle: UIAlertController.Style.alert)
        let action =  UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
        alert.addAction(action)
        
        self.navigationController?.present(alert, animated: true)
    }
    
}
