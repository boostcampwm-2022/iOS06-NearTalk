//
//  LoginDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import Swinject
import UIKit

final class LoginDIContainer {
    private let container: Container
    
    init(container: Container, navigationController: UINavigationController) {
        self.container = Container(parent: container)
    }
    
    func resolveLoginViewController(coordinator: LoginCoordinator) -> LoginViewController {
        return LoginViewController(
            coordinator: coordinator,
            authRepository: self.container.resolve(AuthRepository.self)!
        )
    }
}
