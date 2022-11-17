//
//  LaunchScreenCoordinator.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/12.
//

import UIKit

protocol LaunchScreenCoordinatorDependency {
    func showMainViewController()
    func showLoginViewController()
}

final class LaunchScreenCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private let diContainer: LaunchScreenDIContainer = .init()
    private let dependency: LaunchScreenCoordinatorDependency
    private var launchScreenViewController: LaunchScreenViewController?
    
    // MARK: - Init
    init(
        navigationController: UINavigationController? = nil,
        parentCoordinator: Coordinator? = nil,
        dependency: LaunchScreenCoordinatorDependency
    ) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependency = dependency
    }
    
    // MARK: - Lifecycles
    func start() {
        let actions: LaunchScreenViewModelActions = .init(
            showLoginViewController: self.showLoginViewController,
            showMainViewController: self.showMainViewController
        )
        let viewController: LaunchScreenViewController = self.diContainer.createLaunchScreenViewController(actions: actions)
        self.launchScreenViewController = viewController
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    private func close() {
        self.navigationController?.popViewController(animated: false)
        self.launchScreenViewController = nil
    }
    
    // MARK: - Dependency
    private func showLoginViewController() {
        self.dependency.showLoginViewController()
    }
    
    private func showMainViewController() {
        self.dependency.showMainViewController()
    }
}
