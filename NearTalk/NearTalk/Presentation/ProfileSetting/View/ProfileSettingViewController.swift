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
    }
    
    func bindNickNameField() {
        self.rootView.nickNameText
            .bind(onNext: { [weak self] text in
                self?.viewModel.editNickName(text)
            })
            .disposed(by: self.disposeBag)
        self.viewModel.nickNameValidity
            .asDriver()
            .map { isValid in
                isValid ? "사용 가능한 닉네임 입니다" : "5-16 자 사이의 영어 소문자, 숫자, -_ 기호만 사용하십시오"
            }
            .drive(self.rootView.nickNameValidityMessage)
            .disposed(by: self.disposeBag)
        self.viewModel.nickNameValidity
            .asDriver()
            .map { isValid in
                isValid ? UIColor.green : UIColor.red
            }
            .drive(self.rootView.nickNameValidityColor)
            .disposed(by: self.disposeBag)
        self.rootView.keyboardWillShowOnNickNameField
            .compactMap { self.keyboardNotificationHandler($0) }
            .drive(onNext: { self.moveKeyboardUp(keyboardHeight: $0) })
            .disposed(by: self.disposeBag)
        self.rootView.keyboardWillDismissFromNickNameField
            .filter { self.keyboardNotificationHandler($0) != nil }
            .drive(onNext: { _ in self.moveKeyboardDown() })
            .disposed(by: self.disposeBag)
    }
    
    func bindMessageField() {
        self.rootView.messageText
            .bind(onNext: { [weak self] text in
                self?.viewModel.editStatusMessage(text)
            })
            .disposed(by: self.disposeBag)
        self.viewModel.messageValidity
            .asDriver()
            .map { isValid in
                isValid ? "사용 가능한 메세지 입니다" : "50자 이하로 작성하십시오"
            }
            .drive(self.rootView.messageValidityMessage)
            .disposed(by: self.disposeBag)
        self.viewModel.messageValidity
            .asDriver()
            .map { isValid in
                isValid ? UIColor.green : UIColor.red
            }
            .drive(self.rootView.messageValidityColor)
            .disposed(by: self.disposeBag)
        self.rootView.keyboardWillShowOnMessageField
            .compactMap { self.keyboardNotificationHandler($0) }
            .drive(onNext: { self.moveKeyboardUp(keyboardHeight: $0) })
            .disposed(by: self.disposeBag)
        self.rootView.keyboardWillDismissFromMessageField
            .filter { self.keyboardNotificationHandler($0) != nil }
            .drive(onNext: { _ in self.moveKeyboardDown() })
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
                .bind(to: updateButton.rx.isEnabled)
                .disposed(by: self.disposeBag)
            updateButton.rx
                .tap
                .bind(onNext: { [weak self] in
                    self?.viewModel.update()
                })
                .disposed(by: self.disposeBag)
        }
    }
}

extension UIViewController {
    func keyboardNotificationHandler(_ notification: Notification) -> CGFloat? {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]  as? CGRect else {
            return nil
        }
        return keyboardFrame.height
    }
}

private extension ProfileSettingViewController {
    func moveKeyboardUp(keyboardHeight: CGFloat) {
        self.scrollToUp(keyboardHeight: keyboardHeight)
    }
    
    func moveKeyboardDown() {
        self.scrollToDown()
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
