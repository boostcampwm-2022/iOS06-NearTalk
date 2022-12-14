//
//  UserProfileInputView.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/12/06.
//

import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import UIKit

class UserProfileInputView: UIView {
    // MARK: - UI Space Constants
    private let profileImageSpace: CGFloat = 20.0
    private let profileImageRadius: CGFloat = 75.0
    private let labelSpace: CGFloat = 5.0
    private let labelInset: UIEdgeInsets = .init(top: 0, left: 20.0, bottom: 0, right: 20.0)
    
    // MARK: - Fonts
    private let textFieldTitleLabelFont: UIFont = .ntTextMediumBold
    private let textFieldFont: UIFont = .ntCaption
    private let textFieldValidationMessageFont: UIFont = .ntCaption
    private let registerBtnFont: UIFont = .ntTextSemiBold
    
    // MARK: - UI Properties
    private let pencilSymbol: UIImageView = UIImageView(
        image: UIImage(
            systemName: "pencil.circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 50.0))).then {
        $0.tintColor = .label
    }
    
    private let profileImageView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "photo")
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
        $0.borderStyle = .none
        $0.backgroundColor = .secondaryBackground
        $0.autocorrectionType = .no
        $0.placeholder = "닉네임"
        $0.layer.cornerRadius = 5.0
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.tertiaryLabel?.cgColor
        $0.autocapitalizationType = .none
        $0.clearButtonMode = .always
    }
    
    private let messageField: UITextView = UITextView().then {
        $0.returnKeyType = .done
        $0.isScrollEnabled = false
        $0.backgroundColor = .secondaryBackground
        $0.sizeToFit()
        $0.textContainer.size = $0.contentSize
        $0.textContainer.maximumNumberOfLines = 2
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 5.0
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.tertiaryLabel?.cgColor
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
    }
    
    private let registerButton: UIButton = UIButton().then {
        $0.layer.cornerRadius = 14
        $0.setTitleColor(.whiteLabel, for: .normal)
        $0.backgroundColor = .primaryColor
        $0.isEnabled = false
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.frame = CGRect(origin: .zero, size: $0.intrinsicContentSize)
    }
    
    private let indicator: UIActivityIndicatorView = .init(style: .large).then {
        $0.isHidden = true
        $0.hidesWhenStopped = true
    }
    
    // MARK: - UIView Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .primaryBackground
        self.addSubViews()
        self.bringSubviewToFront(pencilSymbol)
        self.configureFonts()
        self.configureConstraints()
    }
    
    convenience init(inputData: NecessaryProfileComponent) {
        self.init()
        self.nicknameField.text = inputData.nickName
        self.messageField.text = inputData.message
        
        if let imageData = inputData.image,
           let image = UIImage(data: imageData) {
            self.profileImageView.image = image
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.profileImageView.makeRounded()
    }
}

extension UserProfileInputView {
    // MARK: - UI Properties Observables
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
    
    // MARK: - UI Control Events
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
    
    // MARK: - Keyboard Notification
    private var keyboardWillShow: ControlEvent<Notification> {
        return ControlEvent(events: NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification))
    }
    
    private var keyboardWillHide: ControlEvent<Notification> {
        return ControlEvent(events: NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification))
    }
    
    var keyboardWillShowOnNickNameField: Driver<Notification> {
        print(#function)
        return self.keyboardWillShow
            .asDriver()
            .filter { _ in
                self.nicknameField.isFirstResponder
            }
    }
    
    var keyboardWillDismissFromNickNameField: Driver<Notification> {
        print(#function)
        return self.keyboardWillHide
            .asDriver()
            .filter { _ in
                self.nicknameField.isFirstResponder
            }
    }
    
    var keyboardWillShowOnMessageField: Driver<Notification> {
        return self.keyboardWillShow
            .asDriver()
            .filter { _ in
                self.messageField.isFirstResponder
            }
    }
    
    var keyboardWillDismissFromMessageField: Driver<Notification> {
        return self.keyboardWillHide
            .asDriver()
            .filter { _ in
                self.messageField.isFirstResponder
            }
    }
    
    // MARK: - UI Properties Observer
    var profileImage: AnyObserver<UIImage?> {
        return self.profileImageView.rx.image
            .asObserver()
    }
    
    var registerEnable: AnyObserver<Bool> {
        return self.registerButton.rx.isEnabled
            .asObserver()
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
    
    func setButtonTitle(buttonTitle: String) {
        self.registerButton.setTitle(buttonTitle, for: .normal)
    }
    
    func designateMessageViewDelegate(_ delegate: any UITextViewDelegate) {
        self.messageField.delegate = delegate
    }
    
    var loadingIndicator: AnyObserver<Bool> {
        self.indicator.rx.isAnimating
            .asObserver()
    }
}

private extension UserProfileInputView {
    // MARK: - Helpers
    func addSubViews() {
        [pencilSymbol, profileImageView, nickNameLabel, nicknameField, nickNameValidityMessageLabel, messageLabel, messageField, messageValidityMessageLabel, registerButton].forEach {
            self.addSubview($0)
        }
        
        self.registerButton.addSubview(indicator)
    }
    
    func configureFonts() {
        self.nickNameLabel.font = self.textFieldTitleLabelFont
        self.nicknameField.font = self.textFieldFont
        self.nickNameValidityMessageLabel.font = self.textFieldValidationMessageFont
        
        self.messageLabel.font = self.textFieldTitleLabelFont
        self.messageField.font = self.textFieldFont
        self.messageValidityMessageLabel.font = self.textFieldValidationMessageFont
        
        registerButton.titleLabel?.font = self.registerBtnFont
    }
    
    func configureConstraints() {
        self.configurePencilSymbol()
        self.configureProfileImageView()
        self.configureNickNameSection()
        self.configureMessageSection()
        self.configureRegisterButton()
    }
    
    func configurePencilSymbol() {
        pencilSymbol.snp.makeConstraints { make in
            let offset: Float = sqrtf(powf(Float(self.profileImageRadius), 2) / 2)
            make.centerX.equalTo(self.profileImageView.snp.centerX).offset(offset)
            make.centerY.equalTo(self.profileImageView.snp.centerY).offset(offset)
        }
    }
    
    func configureProfileImageView() {
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide).offset(self.profileImageSpace)
            make.width.height.equalTo(self.profileImageRadius * 2)
        }
    }
    
    func configureNickNameSection() {
        nickNameLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(self.labelInset)
            make.top.equalTo(self.profileImageView.snp.bottom).offset(self.profileImageSpace)
        }
        
        nicknameField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(nickNameLabel)
            make.top.equalTo(nickNameLabel.snp.bottom).offset(self.labelSpace)
            make.height.equalTo(self.textFieldFont.pointSize * 3.0)
        }
                
        nickNameValidityMessageLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(nickNameLabel)
            make.top.equalTo(nicknameField.snp.bottom).offset(self.labelSpace)
        }
    }
    
    func configureMessageSection() {
        messageLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(self.labelInset)
            make.top.equalTo(self.nickNameValidityMessageLabel.snp.bottom).offset(10)
        }
        
        messageField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(messageLabel)
            make.top.equalTo(messageLabel.snp.bottom).offset(self.labelSpace)
        }
        
        messageValidityMessageLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(messageLabel)
            make.top.equalTo(messageField.snp.bottom).offset(self.labelSpace)
        }
    }
    
    func configureRegisterButton() {
        registerButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.messageField)
            make.top.equalTo(self.messageValidityMessageLabel).offset(60)
            make.height.equalTo(self.registerButton.snp.width).multipliedBy(0.15)
        }
        
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(indicator.snp.height)
        }
    }
}
