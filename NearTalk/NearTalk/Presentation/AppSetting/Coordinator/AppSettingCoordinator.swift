//
//  AppSettingCoordinator.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/24.
//

import Foundation
import RxSwift
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
        let viewController: AppSettingViewController = self.dependency.makeAppSettingViewController(action: Action(presentLogoutResult: self.presentLogoutResult(success:), presentDropoutResult: self.presentDropoutResult(success:), presentNotificationPrompt: self.presentNotificationPrompt))
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    struct Action: AppSettingAction {
        let presentLogoutResult: ((Bool) -> Void)?
        let presentDropoutResult: ((Bool) -> Void)?
        let presentNotificationPrompt: (() -> Single<Bool>)?
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
    
    func presentNotificationPrompt() -> Single<Bool> {
        return Single<Bool>.create { [weak self] single in
            let alert: UIAlertController = UIAlertController(title: "NearTalk에서 알림을 보내고자 합니다", message: "경고, 사운드 및 아이콘 배지가 알림에 포함될 수 있습니다. 설정에서 이를 구성할 수 있습니다.", preferredStyle: .alert)
            let disallowAction: UIAlertAction = UIAlertAction(title: "허용 안함", style: .cancel, handler: { _ in
                single(.success(false))
            })
            let allowAction: UIAlertAction = UIAlertAction(title: "허용", style: .default) { _ in
                guard let _ = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else {
                    single(.failure(SystemSettingError.noBundleIdentifier))
                    return
                }
                UNUserNotificationCenter.current().requestAuthorization { accept, _ in
                    single(.success(accept))
                    if !accept {
                        Task { [weak self] in
                            await self?.moveToAppSettingPage()
                        }
                    }
                }
            }
            alert.addAction(disallowAction)
            alert.addAction(allowAction)
            self?.navigationController?.topViewController?.present(alert, animated: true)
            return Disposables.create()
        }
    }
    
    @MainActor
    private func moveToAppSettingPage() {
        if #available(iOS 16, *) {
            UIApplication.shared.open(URL(string: UIApplication.openNotificationSettingsURLString)!)
        } else {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    enum SystemSettingError: Error {
        case noBundleIdentifier
    }
}
