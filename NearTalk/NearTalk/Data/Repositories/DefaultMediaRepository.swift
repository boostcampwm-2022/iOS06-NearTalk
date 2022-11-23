//
//  DefaultMediaRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/23.
//

import Foundation
import RxSwift

final class DefaultMediaRepository: MediaRepository {
    private let storageService: StorageService
    
    init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    func uploadImage(_ imageData: Data) -> RxSwift.Single<String> {
        self.storageService.uploadData(data: imageData, fileName: "\(UUID().uuidString).jpg", dataType: .images)
    }
    
    func uploadVideo(_ videoData: Data) -> RxSwift.Single<String> {
        self.storageService.uploadData(data: videoData, fileName: "\(UUID().uuidString).mov", dataType: .videos)
    }
}
