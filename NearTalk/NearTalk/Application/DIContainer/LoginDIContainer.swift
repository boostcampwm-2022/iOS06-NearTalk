//
//  LoginDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import Foundation
import UIKit

final class DefaultLoginCoordinatorDependency: LoginCoordinatorDependency {
    let showOnboardingView: ((String?) -> Void)
    
    init(showOnboardingView: @escaping (String?) -> Void) {
        self.showOnboardingView = showOnboardingView
    }
}

final class LoginDIContainer {
    func makeLoginCoordinatorDependency(showOnboardingView: @escaping (String?) -> Void) -> any LoginCoordinatorDependency {
        return DefaultLoginCoordinatorDependency(showOnboardingView: showOnboardingView)
    }
}
