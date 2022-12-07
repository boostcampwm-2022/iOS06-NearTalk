//
//  OnboardingCoordinator.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/15.
//

import UIKit

final class OnboardingCoordinator: NSObject, Coordinator {
    var navigationController: UINavigationController?
    private let onboardingDIContainer: DefaultOnboardingDIContainer
    
    init(
        container: DefaultOnboardingDIContainer,
        navigationController: UINavigationController?
    ) {
        self.onboardingDIContainer = container
        self.navigationController = navigationController
    }
    
    func start() {
        self.onboardingDIContainer.registerViewModel(action: Action(showMainViewController: self.onboardingDIContainer.showMainViewController, presentRegisterFailure: self.presentRegisterFailure))
        let onboardingViewController: OnboardingViewController = self.onboardingDIContainer.resolveOnboardingViewController()
        self.navigationController?.pushViewController(onboardingViewController, animated: true)
    }
    
    struct Action: OnboardingViewModelAction {
        let showMainViewController: (() -> Void)?
        let presentRegisterFailure: (() -> Void)?
    }
}

extension OnboardingCoordinator {
    func presentRegisterFailure() {
        let alert: UIAlertController = .init(
            title: "등록 실패",
            message: "프로필 등록에 실패했습니다. 조금 있다 다시 시도해보세요",
            preferredStyle: .alert)
        let action: UIAlertAction = .init(title: "OK", style: .destructive)
        alert.addAction(action)
        self.navigationController?.topViewController?.present(alert, animated: true)
    }
}
