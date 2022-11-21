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
    func loginWithApple(token idTokenString: String, nonce: String) -> Observable<FirebaseAuth.User>
    func logout() -> Observable<Bool>
    func deleteCurrentUser() -> Observable<Bool>
}

final class DefaultFirebaseAuthService: FirebaseAuthService {
    
    /// 유저 로그인 확인
    func verifyUser() -> Observable<Bool> {
        return Single<Bool>.create { observer in
            observer(.success(Auth.auth().currentUser != nil))
            return Disposables.create()
        }.asObservable()
    }
    
    /// 유저 로그인
    /// 로그인 한 적 없는 유저는 자동으로 회원가입 된다.
    func loginWithApple(token idTokenString: String, nonce: String) -> Observable<FirebaseAuth.User> {
        Observable<FirebaseAuth.User>.create { observer in
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

                guard let user = authResult?.user else {
                    observer.onError(FirebaseAuthError.nilUser)
                    return
                }
                
                observer.onNext(user)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    /// 로그아웃
    func logout() -> Observable<Bool> {
        Observable<Bool>.create { observer in
            do {
                try Auth.auth().signOut()
                observer.onNext(true)
                observer.onCompleted()
            } catch let error {
                observer.onNext(false)
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    /// 탈퇴
    func deleteCurrentUser() -> Observable<Bool> {
        Observable<Bool>.create { observer in
            Auth.auth().currentUser?.delete { error in
                if let error {
                    observer.onNext(false)
                    observer.onError(error)
                    return
                }
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}

enum FirebaseAuthError: Error {
    case nilUser
}
