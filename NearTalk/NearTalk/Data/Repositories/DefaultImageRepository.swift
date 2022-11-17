//
//  DefaultImageRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation

final class DefaultImageRepository: ImageRepository {
    func save(image: Data) -> String? {
        return nil
    }
    
    func fetch(path: String) -> Data? {
        return nil
    }
}
