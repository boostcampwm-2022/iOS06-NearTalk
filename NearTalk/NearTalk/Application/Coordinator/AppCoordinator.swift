//
//  AppCoordinator.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/11.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController? { get set }
    var parentCoordinator: Coordinator? { get set }
    
    func start()
}

final class AppCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        guard let navigationController else {
            return
        }
        let launchScreenDIContainer: LaunchScreenDIContainer = .init()
        let launchScreenCoordinator: LaunchScreenCoordinator = launchScreenDIContainer.makeLaunchScreenCoordinator(
            navigationController: navigationController,
            dependency: self
        )
        launchScreenCoordinator.start()
    }
}

extension AppCoordinator: LaunchScreenCoordinatorDependency {
    func showMainViewController() {
        self.navigationController?.popViewController(animated: false)
        let rootTabBarCoordinator: RootTabBarCoordinator = RootTabBarDIContainer()
            .makeTabBarCoordinator(navigationController: self.navigationController)
        rootTabBarCoordinator.start()
    }
    
    func showLoginViewController() {
        print(Self.self, #function)
    }
}
