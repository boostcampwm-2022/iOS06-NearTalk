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

final class ProfileSettingView: UIView {
    // MARK: - UI properties
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
}

private extension ProfileSettingView {
    func addSubViews() {
        [profileImageView, nicknameField, messageField].forEach {
            self.addSubview($0)
        }
    }
    
    func configureConstraints() {
        self.configureProfileImageView()
        self.configureNickNameField()
        self.configureMessageField()
    }
    
    func configureProfileImageView() {
        profileImageView.snp.makeConstraints { (make) in
            make.horizontalEdges.top.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(profileImageView.snp.width)
        }
    }
    
    func configureNickNameField() {
        nicknameField.snp.makeConstraints { (make) in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(profileImageView.snp.bottom).offset(30)
            make.height.equalTo(nicknameField.snp.width).multipliedBy(0.15)
        }
    }
    
    func configureMessageField() {
        messageField.snp.makeConstraints { (make) in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(nicknameField.snp.bottom).offset(30)
            make.height.equalTo(messageField.snp.width).multipliedBy(0.15)
        }
    }
}
