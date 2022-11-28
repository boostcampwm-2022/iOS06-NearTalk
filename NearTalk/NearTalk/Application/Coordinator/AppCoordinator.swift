//
//  AppCoordinator.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/11.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController? { get set }
    
    func start()
}

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController?
    private var appDIContainer: AppDIContainer?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.appDIContainer = .init(
            navigationController: navigationController,
            launchScreenActions: .init(
                showLoginViewController: self.showLoginViewController,
                showOnboardingView: self.showOnboardingView,
                showMainViewController: self.showMainViewController
            ),
            loginAction: .init(
                presentMainView: self.showMainViewController,
                presentOnboardingView: self.showOnboardingView,
                presentLoginFailure: { print(#function) }
            ),
            onboardingActions: .init(
                presentImagePicker: nil,
                showMainViewController: self.showMainViewController,
                presentRegisterFailure: nil
            )
        )
    }
    
    func start() {
        guard let appDIContainer else {
            return
        }
        let launchScreenDIContainer: LaunchScreenDIContainer = appDIContainer.resolveLaunchScreenDIContainer()
        let launchScreenCoordinator: LaunchScreenCoordinator = .init(navigationController: navigationController, container: launchScreenDIContainer)
        launchScreenCoordinator.start()
    }
}

extension AppCoordinator: LoginCoordinatorDependency {
    func showLoginViewController() {
        guard let appDIContainer else {
            return
        }
        let loginDIContainer: LoginDIContainer = appDIContainer.resolveLoginDIContainer()
        let loginCoordinator: LoginCoordinator = LoginCoordinator(
            navigationController: self.navigationController,
            container: loginDIContainer
        )
        loginCoordinator.start()
    }
    
    func showMainViewController() {
        guard let appDIContainer else {
            return
        }
        self.navigationController?.popViewController(animated: false)
        let diContainer: RootTabBarDIContainer = appDIContainer.resolveRootTabBarDIContainer()
        let rootTabBarCoordinator: RootTabBarCoordinator = .init(navigationController: self.navigationController, container: diContainer)
        rootTabBarCoordinator.start()
    }
    
    func showOnboardingView() {
        guard let appDIContainer else {
            return
        }
        let onboardingDIContainer: DefaultOnboardingDIContainer = appDIContainer.resolveOnboardingDIContainer()
        let onboardingCoordinator: OnboardingCoordinator = OnboardingCoordinator(
            container: onboardingDIContainer,
            navigationController: self.navigationController
        )
        onboardingCoordinator.start()
    }
}
