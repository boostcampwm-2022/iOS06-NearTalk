//
//  LoginCoordinator.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import AuthenticationServices
import RxSwift

protocol LoginCoordinatorDependency {
//    var showMainViewController: (() -> Void) { get }
    var showOnboardingView: (() -> Void) { get }
    var authRepository: any AuthRepository { get }
}

final class LoginCoordinator: Coordinator {
    var navigationController: UINavigationController?
    
    var parentCoordinator: Coordinator?
    private let dependency: any LoginCoordinatorDependency
    
    func start() {
        self.navigationController?.popViewController(animated: false)
        let loginViewController: LoginViewController = LoginViewController(
            coordinator: self,
            authRepository: self.dependency.authRepository)
        loginViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(loginViewController, animated: true)
//        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    init(navigationController: UINavigationController? = nil, parentCoordinator: Coordinator? = nil, dependency: any LoginCoordinatorDependency) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependency = dependency
    }
    
    func finish() {
        self.navigationController?.dismiss(animated: true)
        self.dependency.showOnboardingView()
    }
}
