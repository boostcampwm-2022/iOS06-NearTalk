//
//  LoadImageUseCase.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/23.
//

import Foundation
import RxSwift

protocol ImageUseCase {
    func saveImage(image: Data) -> String?
    func loadImage(path: String) -> Data?
}

final class DefaultImageUseCase: ImageUseCase {
    private let disposeBag = DisposeBag()
    private let imageRepository: ImageRepository!
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }

    func saveImage(image: Data) -> String? {
        return ""
    }
    
    func loadImage(path: String) -> Data? {
        return Data()
    }
}
