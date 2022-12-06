//
//  LoginViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import AuthenticationServices.ASAuthorization
import Foundation
import RxCocoa
import RxSwift

protocol LoginInput {
    func receiveAppleLoginResult(authorization: ASAuthorization)
    func receiveAppleLoginFailure()
    func requestAppleLogin() -> ASAuthorizationAppleIDRequest
    func viewWillDisappear()
    func viewWillAppear()
}

protocol LoginOutput {
    var loginEnable: Driver<Bool> { get }
}

struct LoginAction {
    var presentMainView: (() -> Void)?
    var presentOnboardingView: (() -> Void)?
    var presentLoginFailure: (() -> Void)?
}

protocol LoginViewModel: LoginInput, LoginOutput {}

final class DefaultLoginViewModel {
    private let action: LoginAction
    private let loginUseCase: any LoginUseCase
    private let verifyUseCase: any VerifyUserUseCase
    private let disposeBag: DisposeBag = DisposeBag()
    private let loginEnableRelay: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    
    init(action: LoginAction,
         loginUseCase: any LoginUseCase,
         verifyUseCase: any VerifyUserUseCase) {
        self.action = action
        self.loginUseCase = loginUseCase
        self.verifyUseCase = verifyUseCase
    }
}

private extension DefaultLoginViewModel {
    func requestFirebaseLogin(token: String) {
        #if DEBUG
        print(#function)
        #endif
        self.loginUseCase.login(token: token)
            .subscribe { [weak self] in
                self?.requestProfileExistence()
            } onError: { [weak self] _ in
                self?.action.presentLoginFailure?()
                self?.loginEnableRelay.accept(true)
            }
            .disposed(by: self.disposeBag)
    }
    
    func requestProfileExistence() {
        #if DEBUG
        print(#function)
        #endif
        self.verifyUseCase.verifyProfile()
            .subscribe { [weak self] in
                self?.action.presentMainView?()
            } onError: { [weak self] _ in
                self?.action.presentOnboardingView?()
            }
            .disposed(by: self.disposeBag)
    }
}

extension DefaultLoginViewModel: LoginViewModel {
    var loginEnable: Driver<Bool> {
        self.loginEnableRelay
            .asDriver()
    }
    
    func receiveAppleLoginResult(authorization: ASAuthorization) {
        #if DEBUG
        print(#function)
        #endif
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let userIdentifier = appleIDCredential.identityToken, let idTokenString = String(data: userIdentifier, encoding: .utf8) else {
                #if DEBUG
                print("Failed to fetch Apple ID Token")
                #endif
                self.loginEnableRelay.accept(true)
                break
            }
            self.requestFirebaseLogin(token: idTokenString)
        default:
            self.loginEnableRelay.accept(true)
        }
    }
    
    func receiveAppleLoginFailure() {
        self.loginEnableRelay.accept(true)
    }

    func requestAppleLogin() -> ASAuthorizationAppleIDRequest {
        #if DEBUG
        print(#function)
        #endif
        self.loginEnableRelay.accept(false)
        let appleIDProvider: ASAuthorizationAppleIDProvider = ASAuthorizationAppleIDProvider()
        let request: ASAuthorizationAppleIDRequest = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        return request
    }
    
    func viewWillAppear() {
        #if DEBUG
        print(#function)
        #endif
        self.loginEnableRelay.accept(true)
    }
    
    func viewWillDisappear() {
        #if DEBUG
        print(#function)
        #endif
        self.loginEnableRelay.accept(false)
    }
}
