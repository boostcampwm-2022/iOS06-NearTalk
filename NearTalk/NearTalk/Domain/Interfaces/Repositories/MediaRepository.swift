//
//  MediaRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/23.
//

import Foundation
import RxSwift

protocol MediaRepository {
    func uploadImage(_ imageData: Data) -> Single<String>
    func uploadVideo(_ videoData: Data) -> Single<String>
    func fetchImage(path: String) -> Single<Data?>
}
