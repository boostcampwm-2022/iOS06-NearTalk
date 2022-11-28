//
//  LoginViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/14.
//

import AuthenticationServices
import RxCocoa
import SnapKit
import Then
import UIKit

final class LoginViewController: UIViewController {
    private let logoView = UIImageView(image: UIImage(systemName: "map.circle.fill"))

    private let loginButton = ASAuthorizationAppleIDButton(type: .default, style: .black).then {
        $0.cornerRadius = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraint()
    }
}

private extension LoginViewController {
    func configureUI() {
        view.addSubview(logoView)
        view.addSubview(loginButton)
    }
    
    func configureConstraint() {
        self.logoView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.bottom.equalTo(loginButton.snp.top).offset(-30)
            make.height.equalTo(logoView.snp.width)
            make.centerX.equalToSuperview()
        }
        
        self.loginButton.snp.makeConstraints { (make) in
            make.horizontalEdges.equalToSuperview().inset(30)
            make.centerY.equalToSuperview()
            make.height.equalTo(loginButton.snp.width).multipliedBy(0.1)
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

// swiftlint:disable: type_name
struct LogInViewController_Preview: PreviewProvider {
    static var previews: some View {
        LoginViewController().showPreview(.iPhone14Pro)
        LoginViewController().showPreview(.iPhoneSE3)
    }
}
#endif
