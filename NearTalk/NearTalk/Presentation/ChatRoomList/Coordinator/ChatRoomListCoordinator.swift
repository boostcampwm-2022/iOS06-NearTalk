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
    private var launchScreenViewController: ChatRoomListViewController?
    
    // MARK: - Init
    init(navigationController: UINavigationController? = nil, parentCoordinator: Coordinator? = nil) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
    }
    
    // MARK: - Lifecycles
    func start() {
        let chatRoomListViewController = ChatRoomListViewController()
        
        navigationController?.pushViewController(chatRoomListViewController, animated: true)
    }
    
    // MARK: - Dependency
    private func showChatRoomViewController() {
        
    }
    
    private func showCreateChatRoomViewController() {
        
    }
    
}
