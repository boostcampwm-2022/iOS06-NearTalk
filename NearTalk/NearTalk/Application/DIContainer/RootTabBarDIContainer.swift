//
//  RootTabBarDIContainer.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import Swinject
import UIKit

final class RootTabBarDIContainer {
    private let container: Container
    
    init(container: Container) {
        self.container = Container(parent: container)
        self.registerViewModel()
    }
    
    private func registerViewModel() {
        self.container.register(RootTabBarViewModel.self) { _ in DefaultRootTabBarViewModel() }
    }
    
    // MARK: - Create viewController
    func resolveRootTabBarViewController() -> RootTabBarController {
        return RootTabBarController(viewModel: container.resolve(RootTabBarViewModel.self)!)
    }
    
    func resolveBackToLoginView() -> (() -> Void)? {
        return self.container.resolve((() -> Void).self)
    }
}
