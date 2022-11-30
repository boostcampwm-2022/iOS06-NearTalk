//
//  AppDIContainer.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/26.
//

import Swinject
import UIKit

final class AppDIContainer {
    private let container: Container
    
    init(
        navigationController: UINavigationController,
        launchScreenActions: LaunchScreenViewModelActions,
        loginAction: LoginAction,
        showMainViewController: (() -> Void)?
    ) {
        self.container = Container()
        self.registerService()
        self.registerRepository()
        
        self.registerLaunchScreenDIContainer(navigationController: navigationController, actions: launchScreenActions)
        self.registerLoginDIContainer(navigationController: navigationController, actions: loginAction)
        self.registerOnboardingDIContainer(showMainViewController: showMainViewController)
        self.registerRootTabBarDIContainer()
    }
    
    private func registerService() {
        self.container.register(FirestoreService.self) { _ in DefaultFirestoreService() }
        self.container.register(AuthService.self) { _ in DefaultFirebaseAuthService() }
        self.container.register(UserDefaultService.self) { _ in DefaultUserDefaultsService() }
    }
    
    private func registerRepository() {
        self.container.register(ProfileRepository.self) { _ in
            DefaultProfileRepository(
                firestoreService: self.container.resolve(FirestoreService.self)!,
                firebaseAuthService: self.container.resolve(AuthService.self)!
            )
        }
        self.container.register(AuthRepository.self) { _ in
            DefaultAuthRepository(authService: self.container.resolve(AuthService.self)!)
        }
        self.container.register(UserDefaultsRepository.self) { _ in
            DefaultUserDefaultsRepository(userDefaultsService: self.container.resolve(UserDefaultService.self)!)
        }
    }
    
    // MARK: - Child DIContainer
    
    // MARK: - LaunchScreenDIContainer
    private func registerLaunchScreenDIContainer(navigationController: UINavigationController, actions: LaunchScreenViewModelActions) {
        self.container.register(LaunchScreenDIContainer.self) { _ in
            LaunchScreenDIContainer(
                container: self.container,
                navigationController: navigationController,
                actions: actions
            )
        }
    }
    
    func resolveLaunchScreenDIContainer() -> LaunchScreenDIContainer {
        return self.container.resolve(LaunchScreenDIContainer.self)!
    }
    
    // MARK: - LoginDIContainer
    private func registerLoginDIContainer(navigationController: UINavigationController, actions: LoginAction) {
        self.container.register(LoginDIContainer.self) { _ in
            LoginDIContainer(
                container: self.container,
                navigationController: navigationController,
                actions: actions
            )
        }
    }
    
    func resolveLoginDIContainer() -> LoginDIContainer {
        return self.container.resolve(LoginDIContainer.self)!
    }
    
    // MARK: - OnboardingDIContainer
    private func registerOnboardingDIContainer(showMainViewController: (() -> Void)?) {
        self.container.register(DefaultOnboardingDIContainer.self) { _ in
            DefaultOnboardingDIContainer(container: self.container, showMainViewController: showMainViewController)
        }
    }
    
    func resolveOnboardingDIContainer() -> DefaultOnboardingDIContainer {
        self.container.resolve(DefaultOnboardingDIContainer.self)!
    }
    
    // MARK: - RootTabBarDIContainer
    private func registerRootTabBarDIContainer() {
        self.container.register(RootTabBarDIContainer.self) { _ in
            RootTabBarDIContainer(container: self.container)
        }
    }
    
    func resolveRootTabBarDIContainer() -> RootTabBarDIContainer {
        self.container.resolve(RootTabBarDIContainer.self)!
    }
    
    func registerBackToLoginClosure(_ closure: @escaping (BackToLoginViewClosure)) {
        self.container.register(BackToLoginViewClosure.self) { _ in
            return closure
        }
    }
}
