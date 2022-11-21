//
//  ProfileSettingViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift
import RxCocoa

protocol ProfileSettingAction {
    var presentImagePicker: () -> Single<Data?> { get }
    var backToMyProfile: () -> Void { get }
}

protocol ProfileSettingInput {
    var nickName: Observable<String> { get }
    var message: Observable<String> { get }
}

protocol ProfileSettingOutput {
    var nickNameValidity: BehaviorRelay<Bool> { get }
    var messageValidity: BehaviorRelay<Bool> { get }
    var registerEnable: BehaviorRelay<Bool> { get }
}

protocol ProfileSettingViewModel {
    init(useCase: any UpdateProfileUseCase, action: any ProfileSettingAction)
    func transform(_ input: ProfileSettingInput) -> ProfileSettingOutput
}

final class DefaultProfileSettingViewModel: ProfileSettingViewModel {
    private let useCase: any UpdateProfileUseCase
    private let action: any ProfileSettingAction

    init(useCase: UpdateProfileUseCase, action: ProfileSettingAction) {
        <#code#>
    }
    
    func transform(_ input: ProfileSettingInput) -> ProfileSettingOutput {
        <#code#>
    }
    
    
}
