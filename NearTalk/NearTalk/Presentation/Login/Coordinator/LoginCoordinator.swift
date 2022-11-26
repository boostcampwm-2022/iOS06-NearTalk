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
    private let dependency: any LoginCoordinatorDependency
    private let loginDIContainer: LoginDIContainer
    
    init(
        navigationController: UINavigationController? = nil,
        dependency: any LoginCoordinatorDependency,
        container: LoginDIContainer
    ) {
        self.navigationController = navigationController
        self.dependency = dependency
        self.loginDIContainer = container
    }
    
    func start() {
        let loginViewController: LoginViewController = loginDIContainer.resolveLoginViewController(coordinator: self)
        self.navigationController?.viewControllers.insert(loginViewController, at: 0)
        self.navigationController?.popViewController(animated: false)
    }
    
    func finish() {
        self.dependency.showOnboardingView()
    }
}
