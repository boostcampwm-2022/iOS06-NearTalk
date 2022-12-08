//
//  MyProfileView.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/12/06.
//

import RxSwift
import UIKit

final class MyProfileView: UIView {
    static let defaultProfileImage: UIImage? = UIImage(
        systemName: "person.crop.circle",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 96))
    
    private let profileImageView: UIImageView = UIImageView(image: MyProfileView.defaultProfileImage).then {
        $0.tintColor = .secondaryLabel
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = false
    }
    
    private let fieldStack: UIStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.axis = .vertical
    }
    
    private let nicknameTitleLabel: UILabel = UILabel().then {
        $0.textAlignment = .natural
        $0.text = "닉네임"
        $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
    }
    
    private let nicknameLabel: UILabel = UILabel().then {
        $0.textAlignment = .natural
        $0.text = "닉네임"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
    private let messageTitleLabel: UILabel = UILabel().then {
        $0.textAlignment = .natural
        $0.text = "상태 메세지"
        $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
    }
    
    private let messageLabel: UILabel = UILabel().then {
        $0.textAlignment = .natural
        $0.text = "상태 메세지"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.configureConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.profileImageView.makeRounded()
    }
}

extension MyProfileView {
    var nickName: Binder<String?> {
        self.nicknameLabel.rx
            .text
    }
    
    var message: Binder<String?> {
        self.messageLabel.rx
            .text
    }
    
    var image: Binder<UIImage?> {
        self.profileImageView.rx
            .image
    }
}

private extension MyProfileView {
    func addSubviews() {
        self.backgroundColor = .primaryBackground
        self.addSubview(profileImageView)
        self.addSubview(fieldStack)
        fieldStack.addArrangedSubview(nicknameTitleLabel)
        fieldStack.addArrangedSubview(nicknameLabel)
        fieldStack.addArrangedSubview(messageTitleLabel)
        fieldStack.addArrangedSubview(messageLabel)
    }
    
    func configureConstraint() {
        profileImageView.snp.makeConstraints {
            $0.leading.verticalEdges.equalToSuperview()
            $0.width.equalTo(profileImageView.snp.height)
        }
        
        fieldStack.snp.makeConstraints {
            $0.verticalEdges.trailing.equalToSuperview()
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
    }
}
