//
//  ProfileSettingCoordinator.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/22.
//

import Foundation
import PhotosUI
import RxRelay
import RxSwift
import UIKit

protocol ProfileSettingCoordinatorDependency {
    func makeProfileSettingViewController(action: ProfileSettingViewModelAction) -> ProfileSettingViewController
}

final class ProfileSettingCoordinator: NSObject, Coordinator {
    private let dependency: any ProfileSettingCoordinatorDependency
    var navigationController: UINavigationController?
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator]
    
    init(navigationController: UINavigationController?,
         parentCoordinator: Coordinator? = nil,
         dependency: any ProfileSettingCoordinatorDependency) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.childCoordinators = []
        self.dependency = dependency
    }
    
    func start() {
        showProfileSettingViewController()
    }
    
    func showProfileSettingViewController() {
        let action: Action = Action(
            presentUpdateFailure: self.presentUpdateFailure)
        let profileSettingViewController: ProfileSettingViewController = self.dependency.makeProfileSettingViewController(action: action)
        self.navigationController?.pushViewController(profileSettingViewController, animated: true)
    }
    
    struct Action: ProfileSettingViewModelAction {
        let presentUpdateFailure: (() -> Void)?
    }
}

extension ProfileSettingCoordinator {
    func presentUpdateFailure() {
        let alert: UIAlertController = .init(
            title: "업데이트 실패",
            message: "프로필 수정에 실패했습니다. 조금 있다 다시 시도해보세요",
            preferredStyle: .alert)
        let action: UIAlertAction = .init(title: "OK", style: .destructive)
        alert.addAction(action)
        self.navigationController?.topViewController?.present(alert, animated: true)
    }
}
