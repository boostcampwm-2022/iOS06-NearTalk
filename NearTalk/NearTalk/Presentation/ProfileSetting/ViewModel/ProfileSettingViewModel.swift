//
//  ProfileSettingViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift
import RxCocoa

protocol ProfileSettingViewModelAction {
    var presentImagePicker: () -> Single<Data?> { get }
}

protocol ProfileSettingInput {
    var nickName: Observable<String> { get }
    var message: Observable<String> { get }
    var register: Observable<Void> { get }
}

protocol ProfileSettingOutput {
    var nickNameValidity: BehaviorRelay<Bool> { get }
    var messageValidity: BehaviorRelay<Bool> { get }
    var registerEnable: BehaviorRelay<Bool> { get }
}

protocol ProfileSettingViewModel {
    init(updateProfileUseCase: any UpdateProfileUseCase,
         validateNickNameUseCase: any ValidateTextUseCase,
         validateStatusMessageUseCase: any ValidateTextUseCase,
         action: any ProfileSettingViewModelAction)
    func transform(_ input: ProfileSettingInput) -> ProfileSettingOutput
    func injectProfile(_ profile: UserProfile)
    func editImage() -> Single<Data?>
}

final class DefaultProfileSettingViewModel: ProfileSettingViewModel {
    private let updateProfileUseCase: any UpdateProfileUseCase
    private let validateNickNameUseCase: any ValidateTextUseCase
    private let validateStatusMessageUseCase: any ValidateTextUseCase
    private let action: any ProfileSettingViewModelAction
    private let disposeBag: DisposeBag = DisposeBag()

    init(updateProfileUseCase: any UpdateProfileUseCase,
         validateNickNameUseCase: any ValidateTextUseCase,
         validateStatusMessageUseCase: any ValidateTextUseCase,
         action: any ProfileSettingViewModelAction) {
        self.updateProfileUseCase = updateProfileUseCase
        self.validateNickNameUseCase = validateNickNameUseCase
        self.validateStatusMessageUseCase = validateStatusMessageUseCase
        self.action = action
    }
    
    struct Input: ProfileSettingInput {
        let nickName: Observable<String>
        let message: Observable<String>
        let register: Observable<Void>
        let imageEdit: Observable<Void>
    }
    
    struct Output: ProfileSettingOutput {
        let nickNameValidity: BehaviorRelay<Bool>
        let messageValidity: BehaviorRelay<Bool>
        let image: BehaviorRelay<Data?>
        let registerEnable: BehaviorRelay<Bool>
    }
    
    func transform(_ input: ProfileSettingInput) -> ProfileSettingOutput {
        let nickNameValidity: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        let messageValidity: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        let registerEnable: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        input.nickName
            .map {
                self.validateNickNameUseCase.execute($0)
            }
            .bind(to: nickNameValidity)
            .disposed(by: self.disposeBag)
        input.message
            .map {
                self.validateStatusMessageUseCase.execute($0)
            }
            .bind(to: messageValidity)
            .disposed(by: self.disposeBag)
        Observable.combineLatest(
            nickNameValidity.asObservable(),
            nickNameValidity.asObservable()) {
                $0 && $1
            }
            .bind(to: registerEnable)
            .disposed(by: self.disposeBag)
        return Output(nickNameValidity: nickNameValidity,
                      messageValidity: nickNameValidity,
                      image: <#T##BehaviorRelay<Data?>#>,
                      registerEnable: registerEnable)
    }
    
    func editImage() -> Single<Data?> {
        return self.action.presentImagePicker()
    }
    
    func injectProfile(_ profile: UserProfile) {
    }
}
