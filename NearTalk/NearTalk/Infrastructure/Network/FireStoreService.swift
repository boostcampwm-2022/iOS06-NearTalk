//
//  FireStoreService.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/12.
//

import Foundation

protocol FireStoreService {
    // 사용자 프로필
    func getUserProfile()
    func createUserProfile()
    func updateUserProfile()
    func deleteUserProfile()
    
    // 친구
    func addFriend()
    func removeFriend()
}

/// FireStore에 데이터 읽기/쓰기를 관리하는 서비스
final class DefaultFireStoreService {
    
}

// MARK: - 사용자 데이터
extension DefaultFireStoreService {
    
}

// MARK: - 친구
extension DefaultFireStoreService {
    
}

// MARK: - 지도 데이터
extension DefaultFireStoreService {
    
}
