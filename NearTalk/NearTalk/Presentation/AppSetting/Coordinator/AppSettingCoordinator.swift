//
//  AppSettingCoordinator.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/24.
//

import Foundation
import UIKit

protocol AppSettingCoordinatorDependency {
    func makeAppSettingViewController(action: AppSettingAction) -> AppSettingViewController
    var backToLoginView: (() -> Void)? { get }
}

final class AppSettingCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var parentCoordinator: Coordinator?
    
    private let dependency: AppSettingCoordinatorDependency
    
    init(navigationController: UINavigationController? = nil, parentCoordinator: Coordinator? = nil, dependency: AppSettingCoordinatorDependency) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependency = dependency
    }
    
    func start() {
        let viewController: AppSettingViewController = self.dependency.makeAppSettingViewController(action: Action(presentLogoutResult: self.presentLogoutResult(success:), presentDropoutResult: self.presentDropoutResult(success:)))
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    struct Action: AppSettingAction {
        let presentLogoutResult: ((Bool) -> Void)?
        let presentDropoutResult: ((Bool) -> Void)?
    }
    
    func presentLogoutResult(success: Bool) {
        let alert: UIAlertController = success ? UIAlertController(title: "로그아웃", message: "로그 아웃되었습니다.", preferredStyle: .alert) : UIAlertController(title: "로그아웃", message: "로그 아웃에 실패했습니다. 다시 해보세요.", preferredStyle: .alert)
        let action: UIAlertAction = success ? UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.dependency.backToLoginView?()
        }) : UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(action)
        self.navigationController?.topViewController?.present(alert, animated: true)
    }
    
    func presentDropoutResult(success: Bool) {
        let alert: UIAlertController = success ? UIAlertController(title: "회원탈퇴", message: "회원 탈퇴되었습니다.", preferredStyle: .alert) : UIAlertController(title: "회원 탈퇴", message: "회원 탈퇴에 실패했습니다. 다시 해보세요.", preferredStyle: .alert)
        let action: UIAlertAction = success ? UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.dependency.backToLoginView?()
        }) : UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(action)
        self.navigationController?.topViewController?.present(alert, animated: true)
    }
}
