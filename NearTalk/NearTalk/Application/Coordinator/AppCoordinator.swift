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
    var childCoordinators: [Coordinator] { get set }

    func start()
}

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController?
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

//    func start() {
//        guard let navigationController else {
//            return
//        }
//        let launchScreenDIContainer: LaunchScreenDIContainer = .init()
//        let childCoordinator: LaunchScreenCoordinator = launchScreenDIContainer.makeLaunchScreenCoordinator(
//            navigationController: navigationController,
//            dependency: self
//        )
//        self.childCoordinators.append(childCoordinator)
//        childCoordinator.start()
//    }
    
    func start() {
        let rootTabBarDIContainer: RootTabBarDIContainer = .init()
        let childCoordinator: RootTabBarCoordinator = rootTabBarDIContainer.makeTabBarCoordinator()
        childCoordinator.navigationController = self.navigationController
        self.childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
}

extension AppCoordinator: LaunchScreenCoordinatorDependency {
    func showMainViewController() {
        print(#function)
    }

    func showLoginViewController() {
        print(#function)
    }
}
