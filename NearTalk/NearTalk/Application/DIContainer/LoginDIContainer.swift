//
//  LoginDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import Foundation
import UIKit

final class LoginDIContainer {
    // MARK: - Service
    func makeAuthService() -> AuthService {
        return DefaultFirebaseAuthService()
    }
    
    // MARK: - Repository
    func makeAuthRepository() -> any AuthRepository {
        return DefaultAuthRepository(authService: makeAuthService())
    }
    
    // MARK: - ViewController
    
    // MARK: - Coordinator
    func makeCoordinator(
        _ navigationController: UINavigationController,
        parentCoordinator: Coordinator,
        dependency: any LoginCoordinatorDependency
    ) -> LoginCoordinator {
        return .init(
            navigationController: navigationController,
            parentCoordinator: parentCoordinator,
            dependency: dependency
        )
    }
}
