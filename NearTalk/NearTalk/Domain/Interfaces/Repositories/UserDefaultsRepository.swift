//
//  UserDefaultsRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/28.
//

import Foundation

protocol UserDefaultsRepository {
    func saveUserProfile(_ profile: UserProfile)
    func fetchUserProfile() -> UserProfile?
    func removeUserProfile()
}
