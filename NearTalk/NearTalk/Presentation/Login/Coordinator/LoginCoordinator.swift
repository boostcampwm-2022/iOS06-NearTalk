//
//  LoginCoordinator.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import AuthenticationServices
import RxSwift

protocol LoginCoordinatorDependency {
    func showMainViewController()
    func showOnboardingView()
}

final class LoginCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var parentCoordinator: Coordinator?
    private let dependency: any LoginCoordinatorDependency
    
    init(
        navigationController: UINavigationController? = nil,
        parentCoordinator: Coordinator? = nil,
        dependency: any LoginCoordinatorDependency
    ) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependency = dependency
    }
    
    func start() {
        let diContainer: LoginDIContainer = .init()
        let loginViewController: LoginViewController = .init(coordinator: self, authRepository: diContainer.makeAuthRepository())
        self.navigationController?.viewControllers.insert(loginViewController, at: 0)
        self.navigationController?.popViewController(animated: false)
    }
    
    func finish() {
        self.dependency.showOnboardingView()
    }
}
