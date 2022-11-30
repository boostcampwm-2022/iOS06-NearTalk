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

    private let nicknameField: UITextField = UITextField().then {
        $0.placeholder = "닉네임"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    private let messageField: UITextField = UITextField().then {
        $0.placeholder = "상태 메세지"
        $0.font = UIFont.systemFont(ofSize: 30)
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
}

extension OnboardingView {
    func makeProfileViewRounded() {
        self.profileImageView.makeRounded()
    }
}

private extension OnboardingView {
    func addSubViews() {
        [logoView, profileImageView, nicknameField, messageField, registerButton].forEach {
            self.addSubview($0)
        }
    }
    
    func configureConstraints() {
        self.configureLogoView()
        self.configureProfileImageView()
        self.configureNickNameField()
        self.configureMessageField()
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
    
    func configureNickNameField() {
        nicknameField.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(profileImageView.snp.bottom).offset(30)
            make.height.equalTo(nicknameField.snp.width).multipliedBy(0.15)
        }
    }
    
    func configureMessageField() {
        messageField.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(nicknameField.snp.bottom).offset(30)
            make.height.equalTo(messageField.snp.width).multipliedBy(0.15)
        }
    }
    
    func configureRegisterButton() {
        registerButton.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(30)
            make.top.greaterThanOrEqualToSuperview().offset(30)
        }
    }
}
