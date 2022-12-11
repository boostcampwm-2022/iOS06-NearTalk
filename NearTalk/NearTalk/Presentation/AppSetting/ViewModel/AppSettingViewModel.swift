//
//  AppSettingViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import RxCocoa
import RxSwift
import UserNotifications

enum AppSettingSection: Hashable & Sendable {
    case main
}

enum AppSettingItem: String, Hashable & Sendable & CaseIterable {
    case logout = "로그아웃"
    case drop = "탈퇴"
    case theme = "테마"
    case alarmOnOff = "알람 on/off"
}

protocol AppSettingAction {
    var presentLogoutResult: ((Bool) -> Void)? { get }
    var presentDropoutResult: ((Bool) -> Void)? { get }
    var presentNotificationPrompt: (() -> Single<Bool>)? { get }
    var presentReauthenticateView: (() -> Void)? { get }
    var showThemeSettingPage: (() -> Void)? { get }
}

protocol AppSettingInput {
    func viewWillAppear()
    func tableRowSelected(item: AppSettingItem?)
    func notificationSwitchToggled(on: Bool)
    func reauthenticate(token: String)
    func failToAuthenticate()
}

protocol AppSettingOutput {
    var notificationOnOffSwitch: Driver<Bool> { get }
    var interactionEnable: Driver<Bool> { get }
}

protocol AppSettingViewModel: AppSettingInput, AppSettingOutput {}

final class DefaultAppSettingViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let logoutUseCase: any LogoutUseCase
    private let dropoutUseCase: any DropoutUseCase
    private let action: any AppSettingAction
    private let notificationOnOff: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let interactionEnableRelay: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    
    static private let appNotificationOnOffKey: String = "appNotificationOnOffKey"
    
    init(
        logoutUseCase: any LogoutUseCase,
        dropoutUseCase: any DropoutUseCase,
        action: any AppSettingAction) {
        self.logoutUseCase = logoutUseCase
        self.dropoutUseCase = dropoutUseCase
        self.action = action
    }
}

extension DefaultAppSettingViewModel: AppSettingViewModel {    
    var interactionEnable: Driver<Bool> {
        self.interactionEnableRelay.asDriver()
    }
    
    var notificationOnOffSwitch: Driver<Bool> {
        self.notificationOnOff.asDriver()
    }
    
    func viewWillAppear() {
        if UserDefaults.standard.object(forKey: DefaultAppSettingViewModel.appNotificationOnOffKey) as? Bool != nil {
            self.notificationOnOff
                .accept(UserDefaults.standard.bool(forKey: DefaultAppSettingViewModel.appNotificationOnOffKey))
        } else {
            self.refreshNotificationAuthorization()
        }
    }
    
    func tableRowSelected(item: AppSettingItem?) {
        guard let item = item
        else {
            return
        }
        
        switch item {
        case .logout:
            self.interactionEnableRelay.accept(false)
            self.requestLogout()
        case .drop:
            self.interactionEnableRelay.accept(false)
            self.action.presentReauthenticateView?()
        case .theme:
            self.action.showThemeSettingPage?()
        default:
            return
        }
    }
    
    func notificationSwitchToggled(on: Bool) {
        if on {
            self.requestNotificationAuthorization()
        } else {
            Task(priority: .high) {
                await UIApplication.shared.unregisterForRemoteNotifications()
            }
            self.notificationOnOff.accept(false)
            UserDefaults.standard.set(false, forKey: DefaultAppSettingViewModel.appNotificationOnOffKey)
        }
    }
    
    func reauthenticate(token: String) {
        self.dropoutUseCase.reauthenticate(token: token)
            .subscribe { [weak self] in
                self?.requestDropout()
            } onError: { [weak self] error in
                #if DEBUG
                print(error)
                #endif
                self?.action.presentDropoutResult?(false)
            }
            .disposed(by: self.disposeBag)
    }
    
    func failToAuthenticate() {
        self.interactionEnableRelay.accept(true)
    }
}

private extension DefaultAppSettingViewModel {
    func requestDropout() {
        self.dropoutUseCase.dropout()
            .subscribe { [weak self] in
                self?.action.presentDropoutResult?(true)
                Task(priority: .high) {
                    await UIApplication.shared.unregisterForRemoteNotifications()
                }
                #warning("Enum으로 UserDefaults 키 관리")
                UserDefaults.standard.set(AppTheme.system.rawValue, forKey: AppTheme.keyName)
                UserDefaults.standard.set(false, forKey: DefaultAppSettingViewModel.appNotificationOnOffKey)
                UserDefaults.standard.removeObject(forKey: DefaultAppSettingViewModel.appNotificationOnOffKey)
                UserDefaults.standard.removeObject(forKey: AppTheme.keyName)
            } onError: { [weak self] _ in
                self?.action.presentDropoutResult?(false)
                self?.interactionEnableRelay.accept(true)
            }
            .disposed(by: self.disposeBag)
    }
    
    func requestLogout() {
        self.logoutUseCase.execute()
            .subscribe { [weak self] in
                self?.action.presentLogoutResult?(true)
                Task(priority: .high) {
                    await UIApplication.shared.unregisterForRemoteNotifications()
                }
            } onError: { [weak self] _ in
                self?.action.presentLogoutResult?(false)
                self?.interactionEnableRelay.accept(true)
            }
            .disposed(by: self.disposeBag)
    }
    
    func requestNotificationAuthorization() {
        guard let result: Single<Bool> = self.action.presentNotificationPrompt?()
        else {
            return
        }
        
        result.subscribe { [weak self] accepted in
            if accepted {
                self?.refreshNotificationAuthorization()
                Task(priority: .high) {
                    await UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                Task(priority: .high) {
                    await UIApplication.shared.unregisterForRemoteNotifications()
                }
                self?.notificationOnOff.accept(false)
                UserDefaults.standard.set(false, forKey: DefaultAppSettingViewModel.appNotificationOnOffKey)
            }
        }
        .disposed(by: self.disposeBag)
    }
    
    func refreshNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let notAllowed: Bool = settings.authorizationStatus == .notDetermined || settings.authorizationStatus == .denied
            self.notificationOnOff.accept(!notAllowed)
            UserDefaults.standard.set(!notAllowed, forKey: DefaultAppSettingViewModel.appNotificationOnOffKey)
        }
    }
}
