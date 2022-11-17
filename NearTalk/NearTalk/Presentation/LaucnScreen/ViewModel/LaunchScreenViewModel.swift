//
//  LaunchScreenViewModel.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/14.
//

import Foundation
import RxCocoa
import RxSwift

struct LaunchScreenViewModelActions {
    let showLoginViewController: () -> Void
    let showMainViewController: () -> Void
}

protocol LaunchScreenViewModelInput {
    
}

protocol LaunchScreenViewModelOutput {
    var isUserAuthenticated: PublishSubject<Bool> { get }
}

protocol LaunchScreenViewModel: LaunchScreenViewModelInput, LaunchScreenViewModelOutput {
    
}

final class DefaultLaunchScreenViewModel: LaunchScreenViewModel {
    private let useCase: LaunchScreenUseCase
    private let actions: LaunchScreenViewModelActions

    let isUserAuthenticated: PublishSubject<Bool>
    private let disposeBag: DisposeBag
    
    init(useCase: LaunchScreenUseCase, actions: LaunchScreenViewModelActions) {
        self.useCase = useCase
        self.actions = actions
        self.isUserAuthenticated = PublishSubject<Bool>()
        self.disposeBag = DisposeBag()
    }
    
    func checkIsAuthenticated() {
        self.useCase.verifyUser()
            .bind(to: self.isUserAuthenticated)
            .disposed(by: self.disposeBag)
    }
}
