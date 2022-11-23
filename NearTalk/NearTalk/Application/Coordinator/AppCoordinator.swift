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
//        self.showMainViewController()
    }
}

extension AppCoordinator: LaunchScreenCoordinatorDependency {
    func showMainViewController() {
        self.navigationController?.popViewController(animated: false)
        guard let rootTabBarCoordinator: RootTabBarCoordinator = RootTabBarDIContainer()
            .makeTabBarCoordinator(navigationController: self.navigationController) else {
            return
        }
        rootTabBarCoordinator.start()
    }
    
    func showLoginViewController() {
//        self.navigationController?.viewControllers.insert(LoginViewController(coordinator: <#LoginCoordinator#>), at: 0)
        self.navigationController?.popViewController(animated: false)
        let loginDIContainer: LoginDIContainer = LoginDIContainer(authRepository: DummyAuthRepository())
        let loginCoordinator: LoginCoordinator = LoginCoordinator(navigationController: self.navigationController, dependency: loginDIContainer.makeLoginCoordinatorDependency(showOnboardingView: self.showOnboardingViewController))
        loginCoordinator.start()
    }
    
    func showOnboardingViewController() {
        self.navigationController?.popViewController(animated: false)
        let onboardingDIContainer: DefaultOnboardingDIContainer = DefaultOnboardingDIContainer(dependency: .init(
            imageRepository: DummyImageRepository(),
            profileRepository: DummyProfileRepository(),
            authRepository: DummyAuthRepository(),
            showMainViewController: self.showMainViewController))
//        let imageService: any StorageService = DefaultStorageService()
//        let storeService: any FirestoreService = DefaultFirestoreService()
//        let authService: any AuthService = DefaultFirebaseAuthService()
//        let onboardingDIContainer: DefaultOnboardingDIContainer = DefaultOnboardingDIContainer(
//            dependency: .init(imageRepository: DefaultImageRepository(imageService: imageService),
//                              profileRepository: DefaultProfileRepository(firestoreService: storeService, firebaseAuthService: authService),
//                              authRepository: DefaultAuthRepository(authService: authService),
//                              showMainViewController: self.showMainViewController))
        onboardingDIContainer.makeOnboardingCoordinator(navigationController: self.navigationController).start()
    }
}
