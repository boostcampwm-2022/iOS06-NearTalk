//
//  StorageService.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/12.
//

import FirebaseStorage
import Foundation
import RxSwift

protocol StorageService {
    func uploadImage(data: Data, fileName: String) -> Single<String>
    func downloadURL(for path: String) -> Single<URL>
}

/// Firebase의 정적 파일 저장소를 관리하는 서비스
final class DefaultStorageService: StorageService {
    private let storage: StorageReference
    
    init() {
        self.storage = Storage.storage().reference()
    }
}

// MARK: - 이미지
extension DefaultStorageService {
    /// Firebase storage에 저장하고 저장된 path를 반환한다.
    func uploadImage(data: Data, fileName: String) -> Single<String> {
        Single<String>.create { [weak self] single in
            guard let self else {
                single(.failure(StorageError.failedToUpload))
                return Disposables.create()
            }
            
            self.storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { _, error in
                guard error == nil else {
                    single(.failure(StorageError.failedToUpload))
                    return
                }
                
                self.storage.child("images/\(fileName)").downloadURL(completion: { url, _ in
                    guard let url = url else {
                        single(.failure(StorageError.failedToGetDownloadUrl))
                        return
                    }
                    let urlString = url.absoluteString
                    single(.success(urlString))
                })
            })
            
            return Disposables.create()
        }
    }
    
    func downloadURL(for path: String) -> Single<URL> {
        Single<URL>.create { [weak self] single in
            guard let self else {
                single(.failure(StorageError.failedToGetDownloadUrl))
                return Disposables.create()
            }
            
            let reference = self.storage.child(path)
            reference.downloadURL { url, error in
                guard let url = url, error == nil else {
                    single(.failure(StorageError.failedToGetDownloadUrl))
                    return
                }
                single(.success(url))
            }
            return Disposables.create()
        }
    }
}

// MARK: - 동영상
extension DefaultStorageService {
    
}

enum StorageError: Error {
    case failedToUpload
    case failedToGetDownloadUrl
}
