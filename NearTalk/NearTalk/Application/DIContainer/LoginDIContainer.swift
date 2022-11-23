//
//  LoginDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import Foundation
import UIKit

final class DefaultLoginCoordinatorDependency: LoginCoordinatorDependency {
    let authRepository: any AuthRepository
    let showOnboardingView: (() -> Void)
    
    init(showOnboardingView: @escaping () -> Void, authRepository: any AuthRepository) {
        self.showOnboardingView = showOnboardingView
        self.authRepository = authRepository
    }
}

final class LoginDIContainer {
    private let authRepository: any AuthRepository
    
    init(authRepository: any AuthRepository) {
        self.authRepository = authRepository
    }
    
    func makeLoginCoordinatorDependency(showOnboardingView: @escaping () -> Void) -> any LoginCoordinatorDependency {
        return DefaultLoginCoordinatorDependency(showOnboardingView: showOnboardingView, authRepository: self.authRepository)
    }
}
