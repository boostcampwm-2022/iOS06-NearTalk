//
//  ProfileSettingViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import Then
import UIKit

final class ProfileSettingViewController: UIViewController {
    // MARK: - UI properties
    private let rootView: ProfileSettingView = ProfileSettingView()
    private let scrollView: UIScrollView = UIScrollView().then {
        $0.keyboardDismissMode = .onDrag
        $0.bounces = false
    }
    
    // MARK: - Properties
    private let disposeBag: DisposeBag = DisposeBag()
    private let loadingViewController: UploadIndicatorViewController = UploadIndicatorViewController().then {
        $0.modalPresentationStyle = .overCurrentContext
    }
    private let viewModel: any ProfileSettingViewModel

    // MARK: - Lifecycles
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = .init(width: self.view.frame.width, height: self.rootView.height)
        self.rootView.frame = .init(origin: .zero, size: self.scrollView.contentSize)
        self.rootView.snp.makeConstraints { make in
            make.edges.equalTo(self.scrollView.contentLayoutGuide)
            make.width.equalToSuperview()
            make.height.equalTo(self.scrollView.contentSize.height)
        }
    }
    
    override func loadView() {
        self.view = self.scrollView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.view.backgroundColor = .white
        self.scrollView.addSubview(self.rootView)
        self.bindToViewModel()
    }
    
    init(viewModel: any ProfileSettingViewModel, neccesaryProfileComponent: NecessaryProfileComponent?) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        if let neccesaryProfileComponent = neccesaryProfileComponent {
            self.rootView.injectProfileData(profileData: neccesaryProfileComponent)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers
private extension ProfileSettingViewController {
    func configureNavigationBar() {
        self.navigationItem.title = "프로필 설정"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "등록", style: .plain, target: self, action: nil)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func bindToViewModel() {
        self.bindNickNameField()
        self.bindMessageField()
        self.bindProfileTap()
        self.bindRegisterButton()
        self.bindBackButton()
    }
    
    func bindNickNameField() {
        self.rootView.nickNameText
            .bind(onNext: { [weak self] text in
                self?.viewModel.editNickName(text)
            })
            .disposed(by: self.disposeBag)
        self.viewModel.nickNameValidity
            .map { isValid in
                isValid ? "사용 가능한 닉네임 입니다" : "5-16 자 사이의 영어 소문자, 숫자, -_ 기호만 사용하십시오"
            }
            .drive(self.rootView.nickNameValidityMessage)
            .disposed(by: self.disposeBag)
        self.viewModel.nickNameValidity
            .map { isValid in
                isValid ? UIColor.green : UIColor.red
            }
            .drive(self.rootView.nickNameValidityColor)
            .disposed(by: self.disposeBag)
        self.rootView.keyboardWillShowOnNickNameField
            .compactMap { self.keyboardNotificationHandler($0) }
            .drive(onNext: { self.moveKeyboardUp(keyboardPopInfo: $0) })
            .disposed(by: self.disposeBag)
        self.rootView.keyboardWillDismissFromNickNameField
            .compactMap { self.keyboardNotificationHandler($0) }
            .drive(onNext: { self.moveKeyboardDown(keyboardPopInfo: $0) })
            .disposed(by: self.disposeBag)
    }
    
    func bindMessageField() {
        self.rootView.messageText
            .bind(onNext: { [weak self] text in
                self?.viewModel.editStatusMessage(text)
            })
            .disposed(by: self.disposeBag)
        self.viewModel.messageValidity
            .map { isValid in
                isValid ? "사용 가능한 메세지 입니다" : "50자 이하로 작성하십시오"
            }
            .drive(self.rootView.messageValidityMessage)
            .disposed(by: self.disposeBag)
        self.viewModel.messageValidity
            .map { isValid in
                isValid ? UIColor.green : UIColor.red
            }
            .drive(self.rootView.messageValidityColor)
            .disposed(by: self.disposeBag)
        self.rootView.keyboardWillShowOnMessageField
            .compactMap { self.keyboardNotificationHandler($0) }
            .drive(onNext: { self.moveKeyboardUp(keyboardPopInfo: $0) })
            .disposed(by: self.disposeBag)
        self.rootView.keyboardWillDismissFromMessageField
            .compactMap { self.keyboardNotificationHandler($0) }
            .drive(onNext: {self.moveKeyboardDown(keyboardPopInfo: $0) })
            .disposed(by: self.disposeBag)
    }
    
    func bindProfileTap() {
        self.rootView.tapProfileEvent
            .bind(onNext: { [weak self] _ in
                self?.viewModel.editImage()
            })
            .disposed(by: self.disposeBag)
        self.viewModel.image
            .asDriver()
            .compactMap { $0 }
            .map { UIImage(data: $0) }
            .drive(self.rootView.profileImage)
            .disposed(by: self.disposeBag)
    }
    
    func bindRegisterButton() {
        if let updateButton = self.navigationItem.rightBarButtonItem {
            self.viewModel.updateEnable
                .drive(updateButton.rx.isEnabled)
                .disposed(by: self.disposeBag)
            updateButton.rx
                .tap
                .bind(onNext: { [weak self] in
                    self?.viewModel.update()
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    func bindBackButton() {
        self.viewModel.backButtonHidden
            .drive(self.navigationItem.rx.hidesBackButton)
            .disposed(by: self.disposeBag)
        self.viewModel.backButtonHidden
            .drive { loadingOn in
                if loadingOn {
                    self.present(self.loadingViewController, animated: true)
                } else {
                    self.loadingViewController.dismiss(animated: true)
                }
            }
            .disposed(by: self.disposeBag)
    }
}

private extension ProfileSettingViewController {
    func moveKeyboardUp(keyboardPopInfo: KeyboardPopInfo) {
        let keyboardSize = keyboardPopInfo.frame.size
        let keyboardHeight = keyboardSize.height
        
        let animator = UIViewPropertyAnimator(duration: keyboardPopInfo.duration, curve: keyboardPopInfo.curve) { [weak self] in
            let transform2D = CGAffineTransform(translationX: 0, y: keyboardHeight)
            self?.view.layer.setAffineTransform(transform2D)
        }
        
        animator.startAnimation()
    }
    
    func moveKeyboardDown(keyboardPopInfo: KeyboardPopInfo) {
        let animator = UIViewPropertyAnimator(duration: keyboardPopInfo.duration, curve: keyboardPopInfo.curve) { [weak self] in
            let transform2D = CGAffineTransform(translationX: 0, y: 0)
            self?.view.layer.setAffineTransform(transform2D)
        }
        
        animator.startAnimation()
//        self.scrollToDown()
    }
    
    func scrollToUp(keyboardHeight: CGFloat) {
        let inset: UIEdgeInsets = .init(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        self.scrollView.contentInset = inset
        self.scrollView.scrollIndicatorInsets = inset
    }
    
    func scrollToDown() {
        self.scrollView.contentInset = .zero
        self.scrollView.scrollIndicatorInsets = .zero
    }
}
