//
//  ProfileDetailUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/16.
//

import Foundation

import RxSwift

final class ProfileDetailUseCase: ProfileDetailUseCaseAble {

    // MARK: - Proporties
    
    var userName: String?
    var statusMessage: String?
    var profileImageURL: String?
    
    // private let repository: UserRepository?
    
    // TODO: - Repository 주입 및 Repository로부터 데이터 받기
    init() {
        self.userName = "userName From Repository"
        self.statusMessage = "statusMessage From Repository"
        self.profileImageURL = "profileImageURL From profileImageURL"
    }
    
    func fetchUserInfo() {
        print(#function)
    }
    
    func deleteUserInFriendList() {
        print(#function)
    }
}
