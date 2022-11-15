//
//  LaunchScreenViewModel.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/14.
//

import Foundation

struct LaunchScreenViewModelActions {
    let showLoginViewController: () -> Void
    let showMainViewController: () -> Void
}

protocol LaunchScreenViewModelInput {
    
}

protocol LaunchScreenViewModelOutput {
    
}

protocol LaunchScreenViewModel: LaunchScreenViewModelInput, LaunchScreenViewModelOutput {
    
}

final class DefaultLaunchScreenViewModel: LaunchScreenViewModel {
    private let useCase: LaunchScreenUseCase
    private let actions: LaunchScreenViewModelActions
    
    init(useCase: LaunchScreenUseCase, actions: LaunchScreenViewModelActions) {
        self.useCase = useCase
        self.actions = actions
    }
    
    func checkIsAuthenticated() {
        _ = useCase.verifyUser()
    }
}
