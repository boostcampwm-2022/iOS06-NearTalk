//
//  LaunchScreenCoordinator.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/12.
//

import UIKit

final class LaunchScreenCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var parentCoordinator: Coordinator?
    private let launchScreenDIContainer: LaunchScreenDIContainer
    
    // MARK: - Init
    init(
        navigationController: UINavigationController?,
        container: LaunchScreenDIContainer
    ) {
        self.navigationController = navigationController
        self.launchScreenDIContainer = container
    }
    
    // MARK: - Lifecycles
    func start() {
        let viewController: LaunchScreenViewController = self.launchScreenDIContainer.resolveLaunchScreenViewController()
        self.navigationController?.pushViewController(viewController, animated: false)
    }
}
