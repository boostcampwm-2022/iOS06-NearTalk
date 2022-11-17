//
//  ImageRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation

protocol ImageRepository {
    func fetch(path: String) -> Data?
    @discardableResult
    func save(image: Data) -> String?
}
