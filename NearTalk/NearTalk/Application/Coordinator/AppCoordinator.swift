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

extension AppCoordinator: LaunchScreenCoordinatorDependency, LoginCoordinatorDependency {
    func showLoginViewController() {
        guard let navigationController = self.navigationController else {
            return
        }
        let loginDIContainer: LoginDIContainer = .init()
        let loginCoordinator: LoginCoordinator = loginDIContainer.makeCoordinator(
            navigationController,
            parentCoordinator: self,
            dependency: self
        )
        loginCoordinator.start()
    }
    
    func showMainViewController() {
        self.navigationController?.popViewController(animated: false)
        let diContainer: RootTabBarDIContainer = .init()
        let rootTabBarCoordinator: RootTabBarCoordinator = diContainer.makeTabBarCoordinator(navigationController: self.navigationController)
        rootTabBarCoordinator.start()
    }
    
    func showOnboardingView() {
        let onboardingDIContainer: DefaultOnboardingDIContainer = .init(dependency: .init(showMainViewController: self.showMainViewController))
        let onboardingCoordinator: OnboardingCoordinator = onboardingDIContainer.makeOnboardingCoordinator(
            navigationController: self.navigationController,
            parent: self
        )
        onboardingCoordinator.start()
    }
}
