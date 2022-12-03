//
//  AuthRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift

protocol AuthRepository {
    func logout() -> Completable
    func dropout() -> Completable
    func login(token: String) -> Completable
    func verify() -> Completable
    func reauthenticate(token: String) -> Completable
}
