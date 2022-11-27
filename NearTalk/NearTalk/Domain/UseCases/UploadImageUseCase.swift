//
//  ImageUploadUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import Foundation
import RxSwift

protocol UploadImageUseCase {
    func execute(image: Data) -> Single<String>
    init(mediaRepository: any MediaRepository)
}

final class DefaultUploadImageUseCase: UploadImageUseCase {
    private let mediaRepository: any MediaRepository

    func execute(image: Data) -> Single<String> {
        return self.mediaRepository.uploadImage(image)
    }
    
    init(mediaRepository: MediaRepository) {
        self.mediaRepository = mediaRepository
    }
}
