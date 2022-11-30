//
//  OnboardingViewPreview.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/30.
//

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct OnboardingViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let appDIContainer: AppDIContainer = AppDIContainer(navigationController: UINavigationController(), launchScreenActions: .init(), loginAction: .init(), showMainViewController: nil)
        let diContainer: DefaultOnboardingDIContainer = appDIContainer.resolveOnboardingDIContainer()
        let viewController: OnboardingViewController = diContainer.resolveOnboardingViewController()
        viewController.showPreview(.iPhoneSE3)
    }
}

#endif
