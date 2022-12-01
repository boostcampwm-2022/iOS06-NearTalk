//
//  ProfileSettingView.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/30.
//

import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import UIKit

typealias KeyboardShowValues = (frame: CGRect, curve: Int, duration: Double)

final class ProfileSettingView: UIView {
    // MARK: - UI properties
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews()
        self.configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func injectProfileData(profileData: NecessaryProfileComponent) {
        self.nicknameField.text = profileData.nickName
        self.messageField.text = profileData.message
        if let imageData = profileData.image {
            self.profileImageView.image = UIImage(data: imageData)
        }
    }
}

extension ProfileSettingView {    
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
    
    var profileImage: AnyObserver<UIImage?> {
        return self.profileImageView.rx.image
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
    
    func moveUpKeyboardAboveNickName(userInfo: [AnyHashable: Any]) {
        print(#function)
        
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let keyboardAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
              let keyboardDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let keyboardCurve = UIView.AnimationCurve(rawValue: keyboardAnimationCurve)
        else {
            return
        }
        
        let keyboardSize: CGRect = keyboardFrame
        let keyboardHeight: CGFloat = keyboardSize.height
        
        let newConstant = keyboardHeight - (self.frame.height - self.profileImageView.frame.height - self.nickNameLabel.frame.height - self.nicknameField.frame.height - self.nickNameValidityMessageLabel.frame.height - 50)
        
        self.profileImageView.snp.remakeConstraints { make in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(profileImageView.snp.width)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(-newConstant)
        }
        
        self.messageLabel.snp.makeConstraints { (make) in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(nickNameValidityMessageLabel.snp.bottom).offset(30 + keyboardHeight)
        }
        
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            self?.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
    
    func moveUpKeyboardAboveMessage(userInfo: [AnyHashable: Any]) {
        print(#function)
        
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let keyboardAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
              let keyboardDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let keyboardCurve = UIView.AnimationCurve(rawValue: keyboardAnimationCurve)
        else {
            return
        }
        
        let keyboardSize: CGRect = keyboardFrame
        let keyboardHeight: CGFloat = keyboardSize.height
        let newConstant = keyboardHeight
        
        self.profileImageView.snp.remakeConstraints { make in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(profileImageView.snp.width)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(-newConstant)
        }
        
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            self?.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }

    func moveDownKeyboard(userInfo: [AnyHashable: Any]) {
        print(#function)
        self.endEditing(true)
        guard let keyboardAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
              let keyboardDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let keyboardCurve = UIView.AnimationCurve(rawValue: keyboardAnimationCurve)
        else {
            return
        }
        
        self.profileImageView.snp.remakeConstraints { make in
            make.horizontalEdges.top.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(profileImageView.snp.width)
        }

        self.messageLabel.snp.makeConstraints { (make) in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(nickNameValidityMessageLabel.snp.bottom).offset(30)
        }
        
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            self?.layoutIfNeeded()
        }
        
        animator.startAnimation()
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

private extension ProfileSettingView {
    func addSubViews() {
        [profileImageView, nickNameLabel, nicknameField, nickNameValidityMessageLabel, messageLabel, messageField, messageValidityMessageLabel].forEach {
            self.addSubview($0)
        }
    }
    
    func configureConstraints() {
        self.configureProfileImageView()
        self.configureNickNameSection()
        self.configureMessageSection()
    }
    
    func configureProfileImageView() {
        profileImageView.snp.makeConstraints { (make) in
            make.horizontalEdges.top.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(profileImageView.snp.width)
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
}
