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
            showLoginViewController: showLoginViewController,
            showMainViewController: showMainViewController
        )
        let viewController: LaunchScreenViewController = diContainer.createLaunchScreenViewController(actions: actions)
        launchScreenViewController = viewController
        navigationController?.pushViewController(viewController, animated: false)
    }
    
    private func close() {
        navigationController?.popViewController(animated: false)
        launchScreenViewController = nil
    }
    
    // MARK: - Dependency
    private func showLoginViewController() {
        dependency.showLoginViewController()
    }
    
    private func showMainViewController() {
        dependency.showMainViewController()
    }
}
