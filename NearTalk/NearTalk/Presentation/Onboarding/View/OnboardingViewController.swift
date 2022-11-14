//
//  OnboardingViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import RxCocoa
import SnapKit
import Then
import UIKit

final class OnboardingViewController: UIViewController {
    private let logoView = UIImageView(image: UIImage(systemName: "map.circle.fill"))
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .lightGray
    }

    private let nicknameField = UITextField().then {
        $0.placeholder = "닉네임"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    private let messageField = UITextField().then {
        $0.placeholder = "상태 메세지"
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    
    private let registerButton = UIButton().then {
        $0.layer.cornerRadius = 5
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemBlue
        $0.isEnabled = false
        $0.setTitle("등록하기", for: .normal)
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.clipsToBounds = true
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
}

private extension OnboardingViewController {
    func configureUI() {
        scrollView.delegate = self
        [logoView, profileImageView, nicknameField, messageField, registerButton].forEach {
            scrollView.addSubview($0)
        }
        view.addSubview(scrollView)
    }
    
    func configureConstraint() {
        scrollView.snp.makeConstraints { (make) in
            make.edges.width.equalToSuperview()
        }
        
        logoView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.height.equalTo(120)
        }
        
        profileImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoView.snp.bottom).offset(30)
            make.width.height.equalTo(120)
        }
        
        nicknameField.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(profileImageView.snp.bottom).offset(30)
            make.height.equalTo(nicknameField.snp.width).multipliedBy(0.15)
        }
        
        messageField.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(nicknameField.snp.bottom).offset(30)
            make.height.equalTo(messageField.snp.width).multipliedBy(0.15)
        }
        
        registerButton.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(messageField.snp.bottom).offset(30)
            make.height.equalTo(registerButton.snp.width).multipliedBy(0.1)
        }
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

// swiftlint:disable: type_name
struct OnbardViewController_Preview: PreviewProvider {
    static var previews: some View {
        OnboardingViewController().showPreview(.iPhone14Pro)
        OnboardingViewController().showPreview(.iPhoneSE3)
    }
}
#endif
