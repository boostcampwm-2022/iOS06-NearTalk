//
//  OnboardingView.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/30.
//

import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import UIKit

final class OnboardingView: UIView {
    // MARK: - UI properties
    private let logoView = UIImageView(image: UIImage(systemName: "map.circle.fill"))
    private let profileImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .lightGray
    }
    
    private let nickNameLabel: UILabel = UILabel().then {
        $0.text = "닉네임"
    }
    
    private let nickNameValidityMessageLabel: UILabel = UILabel().then {
        $0.text = ""
    }
    
    private let messageValidityMessageLabel: UILabel = UILabel().then {
        $0.text = ""
    }
    
    private let messageLabel: UILabel = UILabel().then {
        $0.text = "상태메세지"
    }

    private let nicknameField: UITextField = UITextField().then {
        $0.placeholder = "닉네임"
        $0.borderStyle = .roundedRect
        $0.autocapitalizationType = .none
        $0.clearButtonMode = .always
    }
    
    private let messageField: UITextField = UITextField().then {
        $0.placeholder = "상태 메세지"
        $0.borderStyle = .roundedRect
        $0.autocapitalizationType = .none
        $0.clearButtonMode = .always
    }
    
    private let registerButton: UIButton = UIButton().then {
        $0.layer.cornerRadius = 5
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemBlue
        $0.isEnabled = false
        $0.setTitle("등록하기", for: .normal)
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.frame = CGRect(origin: .zero, size: $0.intrinsicContentSize)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews()
        self.configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OnboardingView {
    var height: CGFloat {
        self.subviews.reduce(30 + 10 + 10 + 30 + 10 + 10 + 30 + 30 + 30) { partialResult, subView in
            partialResult + subView.frame.height
        }
    }
    
    var nickNameText: Observable<String> {
        self.nicknameField.rx.text
            .orEmpty
            .asObservable()
    }
    
    var messageText: Observable<String> {
        self.messageField.rx.text
            .orEmpty
            .asObservable()
    }
    
    var tapProfileEvent: ControlEvent<Void> {
        return ControlEvent(
            events: self.profileImageView.rx
                .tapGesture()
                .when(.ended)
                .map { _ in () })
    }
    
    var registerBtnClickEvent: ControlEvent<Void> {
        return self.registerButton.rx
            .controlEvent(.touchUpInside)
    }
    
    var profileImage: AnyObserver<UIImage?> {
        return self.profileImageView.rx.image
            .asObserver()
    }
    
    var registerEnable: AnyObserver<Bool> {
        return self.registerButton.rx
            .isEnabled
            .asObserver()
    }
    
    private var keyboardWillShow: ControlEvent<Notification> {
        return ControlEvent(events: NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification))
    }
    
    private var keyboardWillHide: ControlEvent<Notification> {
        return ControlEvent(events: NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification))
    }
    
    var keyboardWillShowOnNickNameField: Driver<Notification> {
        return self.keyboardWillShow.asDriver()
            .filter { _ in
                self.nicknameField.isFirstResponder
            }
    }
    
    var keyboardWillDismissFromNickNameField: Driver<Notification> {
        return self.keyboardWillHide.asDriver()
            .filter { _ in
                self.nicknameField.isFirstResponder
            }
    }
    
    var keyboardWillShowOnMessageField: Driver<Notification> {
        return self.keyboardWillShow.asDriver()
            .filter { _ in
                self.messageField.isFirstResponder
            }
    }
    
    var keyboardWillDismissFromMessageField: Driver<Notification> {
        return self.keyboardWillHide.asDriver()
            .filter { _ in
                self.messageField.isFirstResponder
            }
    }
    
    var nickNameValidityMessage: AnyObserver<String?> {
        self.nickNameValidityMessageLabel.rx.text
            .asObserver()
    }
    
    var nickNameValidityColor: AnyObserver<UIColor> {
        self.nickNameValidityMessageLabel.rx.textColor
            .asObserver()
    }
    
    var messageValidityMessage: AnyObserver<String?> {
        self.messageValidityMessageLabel.rx.text
            .asObserver()
    }
    
    var messageValidityColor: AnyObserver<UIColor> {
        self.messageValidityMessageLabel.rx.textColor
            .asObserver()
    }
}

extension OnboardingView {
    func makeProfileViewRounded() {
        self.profileImageView.makeRounded()
    }
}

private extension OnboardingView {
    func addSubViews() {
        [logoView, profileImageView, nickNameLabel, nicknameField, nickNameValidityMessageLabel, messageLabel, messageField, messageValidityMessageLabel, registerButton].forEach {
            self.addSubview($0)
        }
    }
    
    func configureConstraints() {
        self.configureLogoView()
        self.configureProfileImageView()
        self.configureNickNameSection()
        self.configureMessageSection()
        self.configureRegisterButton()
    }
    
    func configureLogoView() {
        logoView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.height.equalTo(120)
        }
    }
    
    func configureProfileImageView() {
        profileImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoView.snp.bottom).offset(30)
            make.width.height.equalTo(160)
        }
    }
    
    func configureNickNameSection() {
        nickNameLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(self.profileImageView.snp.bottom).offset(30)
        }
        
        nicknameField.snp.makeConstraints { (make) in
            make.horizontalEdges.equalTo(nickNameLabel)
            make.top.equalTo(nickNameLabel.snp.bottom).offset(10)
            make.height.equalTo(nicknameField.snp.width).multipliedBy(0.15)
        }
        
        nickNameValidityMessageLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(nickNameLabel)
            make.top.equalTo(nicknameField.snp.bottom).offset(10)
        }
    }
    
    func configureMessageSection() {
        messageLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(self.nickNameValidityMessageLabel.snp.bottom).offset(30)
        }
        
        messageField.snp.makeConstraints { (make) in
            make.horizontalEdges.equalTo(messageLabel)
            make.top.equalTo(messageLabel.snp.bottom).offset(10)
            make.height.equalTo(messageField.snp.width).multipliedBy(0.15)
        }
        
        messageValidityMessageLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(messageLabel)
            make.top.equalTo(messageField.snp.bottom).offset(10)
        }
    }
    
    func configureRegisterButton() {
        registerButton.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(self.messageValidityMessageLabel).offset(30)
            make.height.equalTo(self.registerButton.snp.width).multipliedBy(0.15)
        }
    }
}
