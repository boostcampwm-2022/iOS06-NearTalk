//
//  AppSettingViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import RxCocoa
import RxRelay
import RxSwift
import UserNotifications

enum AppSettingSection: Hashable & Sendable {
    case main
}

enum AppSettingItem: String, Hashable & Sendable & CaseIterable {
    case logout = "로그아웃"
    case drop = "탈퇴"
    case developerInfo = "개발자 정보"
    case alarmOnOff = "알람 on/off"
}

protocol AppSettingAction {
    var presentLogoutResult: ((Bool) -> Void)? { get }
    var presentDropoutResult: ((Bool) -> Void)? { get }
    var presentNotificationPrompt: (() -> Single<Bool>)? { get }
}

protocol AppSettingInput {
    func viewWillAppear()
    func tableRowSelected(item: AppSettingItem?)
    func notificationSwitchToggled(on: Bool)
}

protocol AppSettingOutput {
    var itemSection: BehaviorRelay<AppSettingSection> { get }
    var itemList: BehaviorRelay<[AppSettingItem]> { get }
    var notificationOnOffSwitch: Observable<Bool> { get }
}

protocol AppSettingViewModel: AppSettingInput, AppSettingOutput {}

final class DefaultAppSettingViewModel: AppSettingViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let logoutUseCase: any LogoutUseCase
    private let dropoutUseCase: any DropoutUseCase
    private let action: any AppSettingAction
    
    let itemSection: BehaviorRelay<AppSettingSection> = BehaviorRelay(value: .main)
    let itemList: BehaviorRelay<[AppSettingItem]> = BehaviorRelay(value: AppSettingItem.allCases)
    private let notificationOnOff: PublishRelay<Bool> = PublishRelay()
    
    var notificationOnOffSwitch: Observable<Bool> {
        self.notificationOnOff.asObservable()
    }
    
    init(logoutUseCase: any LogoutUseCase, dropoutUseCase: any DropoutUseCase, action: any AppSettingAction) {
        self.logoutUseCase = logoutUseCase
        self.dropoutUseCase = dropoutUseCase
        self.action = action
        self.refreshNotificationAuthorization()
    }
    
    func viewWillAppear() {
        self.refreshNotificationAuthorization()
    }
    
    private func refreshNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let notAllowed: Bool = settings.authorizationStatus == .notDetermined || settings.authorizationStatus == .denied
            self.notificationOnOff.accept(!notAllowed)
        }
    }
    
    func tableRowSelected(item: AppSettingItem?) {
        guard let item = item else {
            return
        }
        switch item {
        case .logout:
            self.requestLogout()
        case .drop:
            self.requestDropout()
        default:
            return
//        case .developerInfo:
//            <#code#>
//        case .alarmOnOff:
//            <#code#>
        }
    }
    
    func notificationSwitchToggled(on: Bool) {
        if on {
            self.requestNotificationAuthorization()
        } else {
            UIApplication.shared.unregisterForRemoteNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            self.notificationOnOff.accept(false)
        }
    }
    
    private func requestNotificationAuthorization() {
        guard let result: Single<Bool> = self.action.presentNotificationPrompt?() else {
            return
        }
        result.subscribe { [weak self] accepted in
            if accepted {
                self?.refreshNotificationAuthorization()
            } else {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                self?.notificationOnOff.accept(false)
            }
        }
        .disposed(by: self.disposeBag)
    }
    
    private func requestLogout() {
        self.logoutUseCase.execute()
            .subscribe { [weak self] in
                self?.action.presentLogoutResult?(true)
            } onError: { [weak self] _ in
                self?.action.presentLogoutResult?(false)
            }
            .disposed(by: self.disposeBag)
    }
    
    private func requestDropout() {
        self.dropoutUseCase.execute()
            .subscribe { [weak self] in
                self?.action.presentDropoutResult?(true)
            } onError: { [weak self] _ in
                self?.action.presentDropoutResult?(false)
            }
            .disposed(by: self.disposeBag)
    }
}
