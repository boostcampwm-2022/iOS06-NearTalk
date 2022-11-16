//
//  ChattingRoomListCoordinator.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/11.
//

import UIKit

protocol ChattingRoomListCoordinatorDependency {
    func showChatRoomViewController()
    func showCreateChatRoomViewController()
}

class ChattingRoomListCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private var launchScreenViewController: ChattingRoomListViewController?
    
    // MARK: - Init
    init(navigationController: UINavigationController? = nil, parentCoordinator: Coordinator? = nil) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
    }
    
    // MARK: - Lifecycles
    func start() {
        let chattingRoomListViewController = ChattingRoomListViewController()
        
        navigationController?.pushViewController(chattingRoomListViewController, animated: true)
    }
    
    // MARK: - Dependency
    private func showChatRoomViewController() {
        
    }
    
    private func showCreateChatRoomViewController() {
        
    }
    
}
