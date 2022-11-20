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
    
    func start() {
        guard let navigationController else {
            return
        }
        let launchScreenDIContainer: LaunchScreenDIContainer = .init()
        let childCoordinator: LaunchScreenCoordinator = launchScreenDIContainer.makeLaunchScreenCoordinator(
            navigationController: navigationController,
            dependency: self
        )
        self.childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
    
    private func removeChildren() {
        self.childCoordinators.forEach {
            $0.parentCoordinator = nil
        }
        self.childCoordinators = []
    }
    
    private func switchNavigationController(_ navigationController: UINavigationController) {
        guard let window = self.navigationController?.topViewController?.view.window else {
            return
        }
        window.rootViewController = navigationController
        self.navigationController = navigationController
        window.makeKeyAndVisible()
    }
}

extension AppCoordinator: LaunchScreenCoordinatorDependency {
    func showMainViewController() {
        let newNavigationController: UINavigationController = .init()
        let childCoordinator: RootTabBarCoordinator = RootTabBarDIContainer().makeTabBarCoordinator(navigationController: newNavigationController)
        self.switchNavigationController(newNavigationController)
        self.removeChildren()
        self.childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }

    func showLoginViewController() {
        showMainViewController()
    }
}
