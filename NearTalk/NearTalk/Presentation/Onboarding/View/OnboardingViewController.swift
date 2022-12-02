//
//  OnboardingViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class OnboardingViewController: UIViewController {
    // MARK: - UI properties
    private let rootView: OnboardingView = OnboardingView()
    private let scrollView: UIScrollView = UIScrollView().then {
        $0.keyboardDismissMode = .onDrag
        $0.bounces = false
    }
    
    // MARK: - Properties
    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: any OnboardingViewModel
    
    // MARK: - Lifecycles
    init(viewModel: any OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.scrollView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.addSubview(self.rootView)
        self.view.backgroundColor = .white
        self.bindToViewModel()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        self.rootView.makeProfileViewRounded()
        super.viewWillLayoutSubviews()
    }
    
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
}

// MARK: - Helpers
private extension OnboardingViewController {
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
        self.viewModel.registerEnable
            .asDriver()
            .drive(self.rootView.registerEnable)
            .disposed(by: self.disposeBag)
        self.rootView.registerBtnClickEvent
            .bind(onNext: { [weak self] _ in
                self?.viewModel.register()
            })
            .disposed(by: self.disposeBag)
    }
}

private extension OnboardingViewController {
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
