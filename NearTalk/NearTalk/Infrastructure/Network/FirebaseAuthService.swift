//
//  FirebaseAuthService.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/15.
//

import FirebaseAuth
import Foundation
import RxSwift

protocol FirebaseAuthService {
    func verifyUser() -> Observable<Bool>
    func loginWithApple(token idTokenString: String, nonce: String) -> Observable<Bool>
}

final class DefaultFirebaseAuthService: FirebaseAuthService {
    
    func verifyUser() -> Observable<Bool> {
        Observable<Bool>.create { observer in
            if Auth.auth().currentUser != nil {
                observer.onNext(true)
            } else {
                observer.onNext(false)
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func loginWithApple(token idTokenString: String, nonce: String) -> Observable<Bool> {
        Observable<Bool>.create { observer in
            let credential: OAuthCredential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error {
                    observer.onError(error)
                    return
                }
                print("isNewUser: \(String(describing: authResult?.additionalUserInfo?.isNewUser))")
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
