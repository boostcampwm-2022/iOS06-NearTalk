//
//  AppSettingViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import RxRelay
import RxSwift

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
}

protocol AppSettingInput {
    func tableRowSelected(item: AppSettingItem?)
}

protocol AppSettingOutput {
    var itemSection: BehaviorRelay<AppSettingSection> { get }
    var itemList: BehaviorRelay<[AppSettingItem]> { get }
}

protocol AppSettingViewModel: AppSettingInput, AppSettingOutput {}

final class DefaultAppSettingViewModel: AppSettingViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let logoutUseCase: any LogoutUseCase
    private let dropoutUseCase: any DropoutUseCase
    private let action: any AppSettingAction
    
    let itemSection: BehaviorRelay<AppSettingSection> = BehaviorRelay(value: .main)
    let itemList: BehaviorRelay<[AppSettingItem]> = BehaviorRelay(value: AppSettingItem.allCases)
    
    init(logoutUseCase: any LogoutUseCase, dropoutUseCase: any DropoutUseCase, action: any AppSettingAction) {
        self.logoutUseCase = logoutUseCase
        self.dropoutUseCase = dropoutUseCase
        self.action = action
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
