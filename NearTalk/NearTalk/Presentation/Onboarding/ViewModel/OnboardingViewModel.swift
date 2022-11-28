//
//  OnboardingViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/15.
//

import Foundation
import RxRelay
import RxSwift

protocol OnboardingInput {
    func editNickName(_ text: String)
    func editStatusMessage(_ text: String)
    func editImage()
    func register()
}

protocol OnboardingOutput {
    var nickNameValidity: BehaviorRelay<Bool> { get }
    var messageValidity: BehaviorRelay<Bool> { get }
    var image: BehaviorRelay<Data?> { get }
    var registerEnable: BehaviorRelay<Bool> { get }
}

protocol OnboardingViewModel: OnboardingInput, OnboardingOutput {}

protocol OnboardingViewModelAction {
    var presentImagePicker: ((BehaviorRelay<Data?>) -> Void)? { get }
    var showMainViewController: (() -> Void)? { get }
    var presentRegisterFailure: (() -> Void)? { get }
}

final class DefaultOnboardingViewModel: OnboardingViewModel {
    let nickNameValidity: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let messageValidity: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let image: RxRelay.BehaviorRelay<Data?> = BehaviorRelay(value: nil)
    let registerEnable: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
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
        self.bind()
    }
    
    private func bind() {
        Observable.combineLatest(self.nickNameValidity.asObservable(), self.messageValidity.asObservable()) {
            $0 && $1
        }
        .bind(to: self.registerEnable)
        .disposed(by: self.disposeBag)
    }
    
    func editNickName(_ text: String) {
        self.nickName = text
        self.nickNameValidity
            .accept(self.validateNickNameUseCase.execute(text))
    }
    
    func editStatusMessage(_ text: String) {
        self.message = text
        self.messageValidity
            .accept(self.validateStatusMessageUseCase.execute(text))
    }
    
    func editImage() {
        self.action.presentImagePicker?(self.image)
    }
    
    func register() {
        if let image = self.image.value {
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
    
    private func registerProfile(imagePath: String?) {
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
