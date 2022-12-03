//
//  ProfileSettingViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxCocoa
import RxSwift

protocol ProfileSettingInput {
    func editNickName(_ text: String)
    func editStatusMessage(_ text: String)
    func editImage()
    func update()
}

protocol ProfileSettingOutput {
    var nickNameValidity: Driver<Bool> { get }
    var messageValidity: Driver<Bool> { get }
    var image: Driver<Data?> { get }
    var updateEnable: Driver<Bool> { get }
    var goBackEnable: Driver<Bool> { get }
}

protocol ProfileSettingViewModel: ProfileSettingInput, ProfileSettingOutput {}

protocol ProfileSettingViewModelAction {
    var presentImagePicker: ((BehaviorRelay<Data?>) -> Void)? { get }
    var presentUpdateFailure: (() -> Void)? { get }
}

final class DefaultProfileSettingViewModel: ProfileSettingViewModel {
    private let updateProfileUseCase: any UpdateProfileUseCase
    private let validateNickNameUseCase: any ValidateTextUseCase
    private let validateStatusMessageUseCase: any ValidateTextUseCase
    private let uploadImageUseCase: any UploadImageUseCase
    private let action: any ProfileSettingViewModelAction
    private let disposeBag: DisposeBag = DisposeBag()
    
    private var nickName: String?
    private var message: String?
    private var profile: UserProfile
    
    private let nickNameValidityRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let messageValidityRelay: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let imageRelay: BehaviorRelay<Data?> = BehaviorRelay(value: nil)
    private let updateEnableRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let goBackEnableRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var nickNameValidity: Driver<Bool> {
        self.nickNameValidityRelay
            .asDriver()
    }
    var messageValidity: Driver<Bool> {
        self.messageValidityRelay
            .asDriver()
    }
    var image: Driver<Data?> {
        self.imageRelay
            .asDriver()
    }
    
    var updateEnable: Driver<Bool> {
        self.updateEnableRelay
            .asDriver()
    }
    var goBackEnable: Driver<Bool> {
        self.goBackEnableRelay
            .asDriver()
    }
    
    init(updateProfileUseCase: any UpdateProfileUseCase,
         validateNickNameUseCase: any ValidateTextUseCase,
         validateStatusMessageUseCase: any ValidateTextUseCase,
         uploadImageUseCase: any UploadImageUseCase,
         action: any ProfileSettingViewModelAction,
         profile: UserProfile) {
        self.updateProfileUseCase = updateProfileUseCase
        self.validateNickNameUseCase = validateNickNameUseCase
        self.validateStatusMessageUseCase = validateStatusMessageUseCase
        self.uploadImageUseCase = uploadImageUseCase
        self.action = action
        self.nickName = profile.username
        self.message = profile.statusMessage
        self.profile = profile
        self.bind()
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
    
    func editImage() {
        self.action.presentImagePicker?(self.imageRelay)
    }
    
    func update() {
        self.goBackEnableRelay.accept(true)
        if let image = self.imageRelay.value {
            self.uploadImageUseCase.execute(image: image)
                .subscribe(onSuccess: { [weak self] imagePath in
                    self?.updateProfile(imagePath: imagePath)
                }, onFailure: { [weak self] _ in
                    self?.action.presentUpdateFailure?()
                    self?.goBackEnableRelay.accept(false)
                })
                .disposed(by: self.disposeBag)
        } else {
            self.updateProfile(imagePath: nil)
        }
    }
    
    private func updateProfile(imagePath: String?) {
        let newProfile: UserProfile = UserProfile(
            uuid: self.profile.uuid,
            username: self.nickName,
            email: self.profile.email,
            statusMessage: self.message,
            profileImagePath: imagePath,
            friends: self.profile.friends,
            chatRooms: self.profile.chatRooms
        )
        self.updateProfileUseCase.execute(profile: newProfile)
            .subscribe(onCompleted: { [weak self] in
                self?.profile = newProfile
                self?.goBackEnableRelay.accept(false)
            }, onError: { [weak self] _ in
                self?.action.presentUpdateFailure?()
                self?.goBackEnableRelay.accept(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bind() {
        Observable.combineLatest(self.nickNameValidityRelay, self.messageValidityRelay) {
            $0 && $1
        }
        .bind(to: self.updateEnableRelay)
        .disposed(by: self.disposeBag)
    }
}
