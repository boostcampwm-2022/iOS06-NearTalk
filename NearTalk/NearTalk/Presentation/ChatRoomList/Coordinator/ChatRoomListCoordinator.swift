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
}

final class ChatRoomListCoordinator {
    private weak var navigationController: UINavigationController?
    private let dependencies: ChatRoomListCoordinatorDependencies

    private weak var chatRoomListViewController: ChatRoomListViewController?
    
    // MARK: - Init
    init(navigationController: UINavigationController, dependencies: ChatRoomListCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycles
    func start() {
        // 여기서 행동에 대한 강력한 참조를 유지하므로 이 흐름은 강력한 참조가 될 필요가 없다.
        let actions: ChatRoomListViewModelActions = .init(
            showChatRoom: self.showChatRoom,
            showCreateChatRoom: self.showCreateChatRoom
        )
        
        let viewController = dependencies.makeChatRoomListViewController(actions: actions)
        
        self.navigationController?.pushViewController(viewController, animated: false)
        self.chatRoomListViewController = viewController
    }

    // MARK: - Dependency
    private func showChatRoom() {
        // let viewController = dependencies.makeChatRoomViewController(actions: )
        // navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showCreateChatRoom() {
        // let viewController = dependencies.makeChatRoomViewController(actions: )
        // navigationController?.pushViewController(viewController, animated: true)
    }
    
}
