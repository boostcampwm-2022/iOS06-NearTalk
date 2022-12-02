//
//  FirebaseAuthService.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/15.
//

import FirebaseAuth
import Foundation
import RxSwift

final class DefaultFirebaseAuthService: AuthService {
    
    /// 유저 로그인 확인
    func verifyUser() -> Completable {
        Completable.create { completable in
            if Auth.auth().currentUser != nil {
                completable(.completed)
            } else {
                completable(.error(FirebaseAuthError.nilUser))
            }
            return Disposables.create()
        }
    }
    
    /// 현재 유저의 이메일 주소 가져오기
    func fetchCurrentUserEmail() -> Single<String> {
        Single<String>.create { single in
            guard let currentUser: FirebaseAuth.User = Auth.auth().currentUser,
                  let email: String = currentUser.email else {
                single(.failure(FirebaseAuthError.nilUser))
                return Disposables.create()
            }
            single(.success(email))
            return Disposables.create()
        }
    }
    
    /// 유저 로그인
    /// 로그인 한 적 없는 유저는 자동으로 회원가입 된다.
    func loginWithApple(token idTokenString: String, nonce: String) -> Completable {
        Completable.create { completable in
            let credential: OAuthCredential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error {
                    completable(.error(error))
                    return
                }

                guard (authResult?.user) != nil else {
                    completable(.error(FirebaseAuthError.nilUser))
                    return
                }
                completable(.completed)
            }
            return Disposables.create()
        }
    }
    
    /// 로그아웃
    func logout() -> Completable {
        Completable.create { completable in
            do {
                try Auth.auth().signOut()
                completable(.completed)
            } catch let error {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
    
    /// 탈퇴
    func deleteCurrentUser() -> Completable {
        Completable.create { completable in
            guard let user: User = Auth.auth().currentUser else {
                completable(.error(FirebaseAuthError.nilUser))
                return Disposables.create()
            }
            do {
                try Auth.auth().signOut()
            } catch let error {
                completable(.error(error))
            }
            user.delete { error in
                if let error {
                    completable(.error(error))
                    return
                }
                completable(.completed)
            }
            return Disposables.create()
        }
    }
    
    /// 재인증
    func reauthenticateUser(idTokenString: String, nonce: String?) -> Completable {
        Completable.create { completable in
            let credential: OAuthCredential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            Auth.auth().currentUser?.reauthenticate(with: credential, completion: { authResult, error in
                if let error {
                    completable(.error(error))
                    return
                }

                guard (authResult?.user) != nil else {
                    completable(.error(FirebaseAuthError.nilUser))
                    return
                }
                completable(.completed)
            })
            return Disposables.create()
        }
    }
}

enum FirebaseAuthError: Error {
    case nilUser
    case refreshTokenFailed
}
