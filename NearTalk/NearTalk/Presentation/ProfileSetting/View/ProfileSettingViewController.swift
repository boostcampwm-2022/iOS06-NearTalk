//
//  ProfileSettingViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import UIKit

final class ProfileSettingViewController: UserProfileInputViewController {
    // MARK: - Properties
    private let viewModel: any ProfileSettingViewModel

    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rootView.setButtonTitle(buttonTitle: "프로필 수정")
        self.navigationItem.title = "프로필 수정"
    }
    
    init(viewModel: any ProfileSettingViewModel, neccesaryProfileComponent: NecessaryProfileComponent?) {
        self.viewModel = viewModel
        if let neccesaryProfileComponent = neccesaryProfileComponent {
            super.init(inputData: neccesaryProfileComponent)
        } else {
            super.init()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    override func bindNickNameField() {
        super.bindNickNameField()
        
        super.bindDisposable(
            self.rootView.nickNameText
                .bind(onNext: { [weak self] text in
                    self?.viewModel.editNickName(text)
                }),
            
            self.viewModel.nickNameValiditionMessage
                .drive(self.rootView.nickNameValidityMessage),
            
            self.viewModel.nickNameValidity
                .map { isValid in
                    isValid ? UIColor.green : UIColor.red
                }
                .drive(self.rootView.nickNameValidityColor)
        )
    }
    
    override func bindMessageField() {
        super.bindMessageField()
        
        super.bindDisposable(
            self.rootView.messageText
                .bind(onNext: { [weak self] text in
                    self?.viewModel.editStatusMessage(text)
                }),
            
            self.viewModel.messageValiditionMessage
                .drive(self.rootView.messageValidityMessage),
            
            self.viewModel.messageValidity
                .map { isValid in
                    isValid ? UIColor.green : UIColor.red
                }
                .drive(self.rootView.messageValidityColor)
        )
    }
    
    override func bindProfileTap() {
        super.bindDisposable(
            self.rootView.tapProfileEvent
                .bind(onNext: { [weak self] _ in
                    self?.showPHPickerViewController()
                }),
            
            self.viewModel.image
                .compactMap { $0 }
                .map { UIImage(data: $0) }
                .drive(self.rootView.profileImage)
        )
    }
    
    override func imagePicked(_ image: UIImage?) {
        let imageBinary: Data?
        if let image = image {
            imageBinary = self.resizeImageByUIGraphics(image: image)
        } else {
            imageBinary = nil
        }
        self.viewModel.editImage(imageBinary)
    }
    
    override func bindRegisterButton() {
        super.bindDisposable(
            self.viewModel.updateEnable
                .drive(self.rootView.registerEnable),
            
            self.rootView.registerBtnClickEvent
                .bind(onNext: { [weak self] _ in
                    self?.viewModel.update()
                })
        )
    }
    
    func bindBackButton() {
        super.bindDisposable(
            self.viewModel.backButtonHidden
                .drive(self.navigationItem.rx.hidesBackButton),
            
            self.viewModel.backButtonHidden
                .drive { self.rootView.isUserInteractionEnabled = !$0 },
            
            self.viewModel.backButtonHidden
                .drive(self.rootView.loadingIndicator)
        )
    }
    
    override func bindToViewModel() {
        super.bindToViewModel()
        self.bindBackButton()
    }
}
