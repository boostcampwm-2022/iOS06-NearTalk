//
//  ImageUploadUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import Foundation
import RxSwift

protocol UploadImageUseCase {
    func execute(image: Data) -> Single<String?>
    init(imageRepository: any ImageRepository)
}

final class DefaultUploadImageUseCase: UploadImageUseCase {
    private let imageRepository: any ImageRepository

    func execute(image: Data) -> Single<String?> {
        return self.imageRepository.save(image: image)
    }
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }
}
