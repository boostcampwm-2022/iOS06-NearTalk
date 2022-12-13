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
    var nickNameValiditionMessage: Driver<String> { get }
    var messageValiditionMessage: Driver<String> { get }
    var image: Driver<Data?> { get }
    var registerEnable: Driver<Bool> { get }
    var isUploading: Driver<Bool> { get }
}

protocol OnboardingViewModel: OnboardingInput, OnboardingOutput {}

protocol OnboardingViewModelAction {
    var showMainViewController: (() -> Void)? { get }
    var presentRegisterFailure: (() -> Void)? { get }
}

final class DefaultOnboardingViewModel {
    private let nickNameValidition: BehaviorRelay<String> = BehaviorRelay(value: "")
    private let messageValidition: BehaviorRelay<String> = BehaviorRelay(value: "")
    private let imageRelay: BehaviorRelay<Data?> = BehaviorRelay(value: nil)
    private let registerEnableRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let isUploadingRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
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
    var isUploading: Driver<Bool> {
        self.isUploadingRelay
            .asDriver()
    }
    
    var nickNameValidity: Driver<Bool> {
        self.nickNameValidition
            .asDriver()
            .map { $0 == NickNameValidationResult.success.message }
    }
    
    var messageValidity: Driver<Bool> {
        self.messageValidition
            .asDriver()
            .map { $0 == MessageValidationResult.success.message }
    }
    
    var image: Driver<Data?> {
        self.imageRelay.asDriver()
    }
    
    var nickNameValiditionMessage: Driver<String> {
        self.nickNameValidition
            .asDriver()
    }
    
    var messageValiditionMessage: Driver<String> {
        self.messageValidition
            .asDriver()
    }
    
    var registerEnable: Driver<Bool> {
        self.registerEnableRelay.asDriver()
    }
    
    func editNickName(_ text: String) {
        self.nickName = text
        self.nickNameValidition
            .accept(self.validateNickNameUseCase.execute(text))
    }
    
    func editStatusMessage(_ text: String) {
        self.message = text
        self.messageValidition
            .accept(self.validateStatusMessageUseCase.execute(text))
    }
    
    func editImage(_ binary: Data?) {
        self.imageRelay.accept(binary)
    }
    
    func register() {
        self.isUploadingRelay.accept(true)
        if let image = self.imageRelay.value {
            self.uploadImageUseCase.execute(image: image)
                .subscribe(onSuccess: { [weak self] imagePath in
                    self?.registerProfile(imagePath: imagePath)
                }, onFailure: { [weak self] _ in
                    self?.action.presentRegisterFailure?()
                    self?.isUploadingRelay.accept(false)
                })
                .disposed(by: self.disposeBag)
        } else {
            self.registerProfile(imagePath: nil)
        }
    }
}

private extension DefaultOnboardingViewModel {
    func bindRegisterEnable() {
        Observable
            .combineLatest(
                self.nickNameValidity.asObservable(),
                self.messageValidity.asObservable()) { $0 && $1 }
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
        
        UserDefaults.standard.set(imagePath, forKey: UserDefaultsKey.profileImagePath.string)

        self.createProfileUseCase.execute(profile: newProfile)
            .subscribe(onCompleted: { [weak self] in
                self?.action.showMainViewController?()
                self?.isUploadingRelay.accept(false)
            }, onError: { [weak self] _ in
                self?.action.presentRegisterFailure?()
                self?.isUploadingRelay.accept(false)
            })
            .disposed(by: self.disposeBag)
    }
}
