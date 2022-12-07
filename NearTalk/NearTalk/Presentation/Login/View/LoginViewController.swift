//
//  LoginViewController.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import AuthenticationServices
import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import Then
import UIKit

final class LoginViewController: UIViewController {
    private let logoView = UIImageView(image: UIImage(systemName: "map.circle.fill"))
    private let loginButton: ASAuthorizationAppleIDButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline).then {
        $0.cornerRadius = 5
    }
    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: any LoginViewModel
    
    init(viewModel: any LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraint()
        self.bindToLoginButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.viewModel.viewWillDisappear()
        super.viewWillDisappear(animated)
    }
}
private extension LoginViewController {
    func configureUI() {
        self.view.backgroundColor = .systemBackground
        view.addSubview(logoView)
        view.addSubview(loginButton)
    }
    func configureConstraint() {
        self.logoView.snp.makeConstraints { (make) in
            make.height.width.equalTo(240)
            make.center.equalToSuperview()
        }
        
        self.loginButton.snp.makeConstraints { (make) in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(loginButton.snp.width).multipliedBy(0.15)
        }
    }

    func bindToLoginButton() {
        self.viewModel.loginEnable
            .drive(self.loginButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        loginButton.rx.tapGesture()
            .bind {
                if $0.state == .ended {
                    self.loginPressed()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func loginPressed() {
        let request: ASAuthorizationAppleIDRequest = self.viewModel.requestAppleLogin()
        
        let authorizationController: ASAuthorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        #if DEBUG
        print(#function)
        #endif
        self.viewModel.receiveAppleLoginResult(authorization: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
#if DEBUG
        print(#function)
        print("apple authorization error: \(error)")
#endif
        self.viewModel.receiveAppleLoginFailure()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
