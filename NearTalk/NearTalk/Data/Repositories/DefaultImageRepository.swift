//
//  DefaultImageRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation
import RxSwift

final class DefaultImageRepository: ImageRepository {
    private let imageService: any StorageService
    private let disposeBag: DisposeBag = DisposeBag()

    init(imageService: any StorageService) {
        self.imageService = imageService
    }
    
    func fetch(path: String) -> RxSwift.Single<Data?> {
        return Single.just(nil)
    }
    
    func save(image: Data) -> RxSwift.Single<String> {
        return self.imageService.uploadData(data: image, fileName: "DefaultImage", dataType: .images)
    }
}
