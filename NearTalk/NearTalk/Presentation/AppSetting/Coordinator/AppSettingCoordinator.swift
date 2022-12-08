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
    
    init(
        navigationController: UINavigationController? = nil,
        parentCoordinator: Coordinator? = nil,
        dependency: AppSettingCoordinatorDependency) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependency = dependency
    }
    
    func start() {
        let viewController: AppSettingViewController = self.dependency.makeAppSettingViewController(
            action: Action(presentLogoutResult: self.presentLogoutResult(success:),
                           presentDropoutResult: self.presentDropoutResult(success:),
                           presentNotificationPrompt: self.presentNotificationPrompt,
                           presentReauthenticateView: self.presentAppleAuthenticateViewController, showThemeSettingPage: self.showThemeSettingPage))
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    struct Action: AppSettingAction {
        let presentLogoutResult: ((Bool) -> Void)?
        let presentDropoutResult: ((Bool) -> Void)?
        let presentNotificationPrompt: (() -> Single<Bool>)?
        let presentReauthenticateView: (() -> Void)?
        let showThemeSettingPage: (() -> Void)?
    }
    
    func presentLogoutResult(success: Bool) {
        let alert: UIAlertController = success
        ? UIAlertController(
            title: "로그아웃",
            message: "로그아웃 되었습니다.",
            preferredStyle: .alert)
        : UIAlertController(
            title: "로그아웃",
            message: "로그아웃에 실패했습니다. 다시 해보세요.",
            preferredStyle: .alert)
        
        let action: UIAlertAction = success
        ? UIAlertAction(
            title: "확인",
            style: .default) { [weak self] _ in
            self?.dependency.backToLoginView?() }
        : UIAlertAction(
            title: "취소",
            style: .cancel)
        
        alert.addAction(action)
        self.navigationController?.topViewController?.present(alert, animated: true)
    }
    
    func presentDropoutResult(success: Bool) {
        let alert: UIAlertController = success
        ? UIAlertController(
            title: "회원탈퇴",
            message: "회원탈퇴 되었습니다.",
            preferredStyle: .alert)
        : UIAlertController(
            title: "회원탈퇴",
            message: "회원탈퇴에 실패했습니다. 다시 해보세요.",
            preferredStyle: .alert)
        
        let action: UIAlertAction = success
        ? UIAlertAction(
            title: "확인",
            style: .default) { [weak self] _ in
            self?.dependency.backToLoginView?() }
        : UIAlertAction(
            title: "취소",
            style: .cancel)
        
        alert.addAction(action)
        self.navigationController?.topViewController?.present(alert, animated: true)
    }
    
    func presentNotificationPrompt() -> Single<Bool> {
        return Single<Bool>.create { [weak self] single in
            let alert: UIAlertController = UIAlertController(
                title: "NearTalk에서 알림을 보내고자 합니다",
                message: "경고, 사운드 및 아이콘 배지가 알림에 포함될 수 있습니다. 설정에서 이를 구성할 수 있습니다.",
                preferredStyle: .alert)
            
            let disallowAction: UIAlertAction = UIAlertAction(
                title: "허용 안함",
                style: .cancel) { _ in
                single(.success(false))
            }
            
            let allowAction: UIAlertAction = UIAlertAction(
                title: "허용",
                style: .default) { _ in
                guard Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String != nil
                else {
                    single(.failure(SystemSettingError.noBundleIdentifier))
                    
                    return
                }
                    
                UNUserNotificationCenter.current().requestAuthorization { accept, _ in
                    single(.success(accept))
                    
                    if !accept {
                        Task(priority: .high) { [weak self] in
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
    
    func presentAppleAuthenticateViewController() {
        guard let appSettingController = self.navigationController?.topViewController as? AppSettingViewController
        else {
            return
        }
        
        appSettingController.presentReauthenticationViewController()
    }
    
    func showThemeSettingPage() {
        let themeSettingViewModel: any ThemeSettingViewModel = DefaultThemeSettingViewModel()
        let viewController: ThemeSettingViewController = ThemeSettingViewController(viewModel: themeSettingViewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @MainActor
    private func moveToAppSettingPage() async {
        if #available(iOS 16, *) {
            await UIApplication.shared.open(URL(string: UIApplication.openNotificationSettingsURLString)!)
        } else {
            await UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    enum SystemSettingError: Error {
        case noBundleIdentifier
    }
}
