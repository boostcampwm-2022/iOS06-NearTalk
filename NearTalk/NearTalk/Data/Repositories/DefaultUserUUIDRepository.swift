//
//  DefaultUserUUIDRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation

final class DefaultUserUUIDRepository: UserUUIDRepository {
    func fetch() -> String {
        return UUID().uuidString
    }
}
