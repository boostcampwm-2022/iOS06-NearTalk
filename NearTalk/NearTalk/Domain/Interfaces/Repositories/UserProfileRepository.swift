//
//  UserProfileRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation

protocol UserProfileRepository {
    func save(_ profile: UserProfile)
    func load(uuid: String) -> UserProfile
}
