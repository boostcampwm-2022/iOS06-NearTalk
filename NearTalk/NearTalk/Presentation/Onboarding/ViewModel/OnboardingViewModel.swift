//
//  OnboardingViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/15.
//

import Foundation
import RxCocoa
import RxSwift

protocol OnboardingInput {
    func editNickName(_ text: String)
    func editStatusMessage(_ text: String)
    func editImage(_ binary: Data?)
    func register()
}

protocol OnboardingOutput {
    var nickNameValidity: Driver<Bool> { get }
    var messageValidity: Driver<Bool> { get }
    var image: Driver<Data?> { get }
    var registerEnable: Driver<Bool> { get }
}

protocol OnboardingViewModel: OnboardingInput, OnboardingOutput {}

protocol OnboardingViewModelAction {
    var showMainViewController: (() -> Void)? { get }
    var presentRegisterFailure: (() -> Void)? { get }
}

final class DefaultOnboardingViewModel {
    private let nickNameValidityRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let messageValidityRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let imageRelay: BehaviorRelay<Data?> = BehaviorRelay(value: nil)
    private let registerEnableRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    private let validateNickNameUseCase: any ValidateTextUseCase
    private let validateStatusMessageUseCase: any ValidateTextUseCase
    private let uploadImageUseCase: any UploadImageUseCase
    private let createProfileUseCase: any CreateProfileUseCase
    private let action: any OnboardingViewModelAction
    private let disposeBag: DisposeBag = DisposeBag()
    
    private var nickName: String = ""
    private var message: String = ""
    
    init(
        validateNickNameUseCase: any ValidateTextUseCase,
        validateStatusMessageUseCase: any ValidateTextUseCase,
        uploadImageUseCase: any UploadImageUseCase,
        createProfileUseCase: any CreateProfileUseCase,
        action: any OnboardingViewModelAction
    ) {
        self.validateNickNameUseCase = validateNickNameUseCase
        self.validateStatusMessageUseCase = validateStatusMessageUseCase
        self.uploadImageUseCase = uploadImageUseCase
        self.createProfileUseCase = createProfileUseCase
        self.action = action
        self.bindRegisterEnable()
    }
}

extension DefaultOnboardingViewModel: OnboardingViewModel {
    var image: Driver<Data?> {
        self.imageRelay.asDriver()
    }
    
    var nickNameValidity: Driver<Bool> {
        self.nickNameValidityRelay.asDriver()
    }
    
    var messageValidity: Driver<Bool> {
        self.messageValidityRelay.asDriver()
    }
    
    var registerEnable: Driver<Bool> {
        self.registerEnableRelay.asDriver()
    }
    
    func editNickName(_ text: String) {
        self.nickName = text
        self.nickNameValidityRelay
            .accept(self.validateNickNameUseCase.execute(text))
    }
    
    func editStatusMessage(_ text: String) {
        self.message = text
        self.messageValidityRelay
            .accept(self.validateStatusMessageUseCase.execute(text))
    }
    
    func editImage(_ binary: Data?) {
        self.imageRelay.accept(binary)
    }
    
    func register() {
        if let image = self.imageRelay.value {
            self.uploadImageUseCase.execute(image: image)
                .subscribe(onSuccess: { [weak self] imagePath in
                    self?.registerProfile(imagePath: imagePath)
                }, onFailure: { [weak self] _ in
                    self?.action.presentRegisterFailure?()
                })
                .disposed(by: self.disposeBag)
        } else {
            self.registerProfile(imagePath: nil)
        }
    }
}

private extension DefaultOnboardingViewModel {
    func bindRegisterEnable() {
        Observable.combineLatest(self.nickNameValidityRelay, self.messageValidityRelay) {
            $0 && $1
        }
        .bind(to: self.registerEnableRelay)
        .disposed(by: self.disposeBag)
    }
    
    func registerProfile(imagePath: String?) {
        let newProfile: UserProfile = UserProfile(
            uuid: UUID().uuidString,
            username: self.nickName,
            email: nil,
            statusMessage: self.message,
            profileImagePath: imagePath
        )
        self.createProfileUseCase.execute(profile: newProfile)
            .subscribe(onCompleted: { [weak self] in
                self?.action.showMainViewController?()
            }, onError: { [weak self] _ in
                self?.action.presentRegisterFailure?()
            })
            .disposed(by: self.disposeBag)
    }
}
