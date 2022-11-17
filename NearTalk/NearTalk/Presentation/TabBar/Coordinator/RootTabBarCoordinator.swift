//
//  RootTabBarCoordinator.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import UIKit

final class RootTabBarCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    func start() {
        let diContainer: RootTabBarDIContainer = .init()
        let viewcontroller: RootTabBarController = diContainer.createTabBarController()
        self.navigationController?.pushViewController(viewcontroller, animated: false)
    }
    
}
