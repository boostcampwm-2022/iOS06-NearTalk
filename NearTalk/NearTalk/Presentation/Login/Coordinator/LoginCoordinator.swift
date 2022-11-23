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
    var showOnboardingView: ((String?) -> Void) { get }
}

final class LoginCoordinator: Coordinator {
    var navigationController: UINavigationController?
    
    var parentCoordinator: Coordinator?
    private let dependency: any LoginCoordinatorDependency
    
    func start() {
        self.navigationController?.popViewController(animated: false)
        let loginViewController: LoginViewController = LoginViewController(coordinator: self)
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    init(navigationController: UINavigationController? = nil, parentCoordinator: Coordinator? = nil, dependency: any LoginCoordinatorDependency) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependency = dependency
    }
    
    func finish(email: String?) {
        self.dependency.showOnboardingView(email)
    }
}
