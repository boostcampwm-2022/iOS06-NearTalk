//
//  ProfileSettingViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxRelay
import RxSwift

protocol ProfileSettingInput {
    func editNickName(_ text: String)
    func editStatusMessage(_ text: String)
    func editImage()
    func update()
}

protocol ProfileSettingOutput {
    var nickNameValidity: BehaviorRelay<Bool> { get }
    var messageValidity: BehaviorRelay<Bool> { get }
    var image: BehaviorRelay<Data?> { get }
    var updateEnable: BehaviorRelay<Bool> { get }
}

protocol ProfileSettingViewModel: ProfileSettingInput, ProfileSettingOutput {}

protocol ProfileSettingViewModelAction {
    var presentImagePicker: ((BehaviorRelay<Data?>) -> Void)? { get }
    var presentUpdateFailure: (() -> Void)? { get }
}

final class DefaultProfileSettingViewModel: ProfileSettingViewModel {
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
    
    func update() {
        if let image = self.image.value {
            self.uploadImageUseCase.execute(image: image)
                .subscribe(onSuccess: { [weak self] imagePath in
                    self?.updateProfile(imagePath: imagePath)
                }, onFailure: { [weak self] _ in
                    self?.action.presentUpdateFailure?()
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
            chatRooms: self.profile.chatRooms)
        self.updateProfileUseCase.execute(profile: newProfile)
            .subscribe(onCompleted: { [weak self] in
                self?.profile = newProfile
            }, onError: { [weak self] _ in
                self?.action.presentUpdateFailure?()
            })
            .disposed(by: self.disposeBag)
    }
    
    let nickNameValidity: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let messageValidity: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let image: RxRelay.BehaviorRelay<Data?> = BehaviorRelay(value: nil)
    let updateEnable: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    private let updateProfileUseCase: any UpdateProfileUseCase
    private let validateNickNameUseCase: any ValidateTextUseCase
    private let validateStatusMessageUseCase: any ValidateTextUseCase
    private let uploadImageUseCase: any UploadImageUseCase
    private let action: any ProfileSettingViewModelAction
    private let disposeBag: DisposeBag = DisposeBag()
    
    private var nickName: String?
    private var message: String?
    private var profile: UserProfile
    
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
    
    private func bind() {
        Observable.combineLatest(self.nickNameValidity.asObservable(), self.messageValidity.asObservable()) {
            $0 && $1
        }
        .bind(to: self.updateEnable)
        .disposed(by: self.disposeBag)
    }
}
