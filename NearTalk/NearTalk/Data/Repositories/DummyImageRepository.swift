//
//  DummyImageRepository.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/23.
//

import Foundation
import RxSwift

enum DummyImageRepoError: Error {
    case notFound
}

final class DummyImageRepository: ImageRepository {
    private let disposeBag: DisposeBag = DisposeBag()
    
    func fetch(path: String) -> Single<Data?> {
        return Single.create { single in
            guard let image = UserDefaults.standard.data(forKey: path) else {
                single(.failure(DummyImageRepoError.notFound))
                return Disposables.create()
            }
            single(.success(image))
            return Disposables.create()
        }
    }
    
    func save(image: Data) -> Single<String> {
        return Single.create { single in
            let fileName: String = CACurrentMediaTime().formatted()
            UserDefaults.standard.set(image, forKey: fileName)
            single(.success(fileName))
            return Disposables.create()
        }
    }
}
