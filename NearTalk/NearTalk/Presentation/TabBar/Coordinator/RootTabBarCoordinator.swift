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
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewcontroller: RootTabBarController = RootTabBarDIContainer().createTabBarController()
        self.navigationController?.viewControllers.insert(viewcontroller, at: 0)
        self.navigationController?.popToRootViewController(animated: false)
    }
}
