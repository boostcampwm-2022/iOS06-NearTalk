//
//  ImageRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation
import RxSwift

protocol ImageRepository {
    func fetch(path: String) -> Single<Data?>
    func save(image: Data) -> Single<String>
}
