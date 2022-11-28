//
//  FirestoreService.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/19.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import RxSwift

protocol FirestoreService {
    /// 객체 저장
    func create<T: BaseEntity>(data: T, dataKey: FirebaseKey.FireStore) -> Single<T>
    /// 객체 불러오기 (uuid로 불러오기)
    func fetch<T: BaseEntity>(dataKey: FirebaseKey.FireStore, queryList: [FirebaseQueryDTO]) -> Single<T>
    /// 객체 수정
    func update<T: BaseEntity>(updatedData: T, dataKey: FirebaseKey.FireStore) -> Single<T>
    /// 객체 삭제
    func delete<T: BaseEntity>(data: T, dataKey: FirebaseKey.FireStore ) -> Completable
    
    /// 객체 리스트 불러오기
    func fetchList<T: BaseEntity>(dataKey: FirebaseKey.FireStore, queryList: [FirebaseQueryDTO]) -> Single<[T]>
}

final class DefaultFirestoreService: FirestoreService {
    private let db: Firestore
    
    init() {
        self.db = Firestore.firestore()
    }
    
    /// 객체 저장
    func create<T: BaseEntity>(data: T, dataKey: FirebaseKey.FireStore) -> Single<T> {
        Single<T>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreError.failedToCreate))
                return Disposables.create()
            }
            do {
                try self.db.collection(dataKey.rawValue).document().setData(data.encode()) { err in
                    if let err {
                        single(.failure(err))
                    } else {
                        single(.success(data))
                    }
                }
            } catch let error {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    /// 객체 불러오기
    func fetch<T: BaseEntity>(dataKey: FirebaseKey.FireStore, queryList: [FirebaseQueryDTO]) -> Single<T> {
        Single<T>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreError.failedToFetch))
                return Disposables.create()
            }
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(dataKey.rawValue)
            guard let query: FirebaseFirestore.Query = self.makeQuery(docRef: docRef, queryList: queryList) else {
                single(.failure(FirebaseStoreError.invalidQuery))
                return Disposables.create()
            }
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let dictionary: [String: Any] = snapshot?.documents.first?.data(),
                      let data: T = try? T.decode(dictionary: dictionary) else {
                    single(.failure(FirebaseStoreError.failedToFetch))
                    return
                }
                single(.success(data))
            }
            return Disposables.create()
        }
    }
    
    /// 객체 수정
    func update<T: BaseEntity>(updatedData: T, dataKey: FirebaseKey.FireStore) -> Single<T> {
        Single<T>.create { [weak self] single in
            guard let self,
                  let uuid = updatedData.uuid else {
                single(.failure(FirebaseStoreError.invalidUUID))
                return Disposables.create()
            }
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(dataKey.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("UUID", isEqualTo: uuid)
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let document: QueryDocumentSnapshot = snapshot?.documents.first,
                      let data: T = try? T.decode(dictionary: document.data()) else {
                    single(.failure(FirebaseStoreError.failedToFetch))
                    return
                }
                if dataKey == .users,
                   var newData: UserProfile = data as? UserProfile,
                   let updated: UserProfile = updatedData as? UserProfile {
                    let email: String? = newData.email
                    newData = updated
                    newData.email = email // 유저의 이메일은 고유값이라 수정하면 안됨
                    try? document.reference.setData(newData.encode()) { error in
                        if let error {
                            single(.failure(error))
                        } else {
                            single(.success(updatedData))
                        }
                    }
                } else {
                    try? document.reference.setData(updatedData.encode()) { error in
                        if let error {
                            single(.failure(error))
                        } else {
                            single(.success(updatedData))
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    /// 객체 삭제
    func delete<T: BaseEntity>(data: T, dataKey: FirebaseKey.FireStore ) -> Completable {
        Completable.create { [weak self] completable in
            guard let self,
                  let uuid = data.uuid else {
                completable(.error(FirebaseStoreError.failedToDelete))
                return Disposables.create()
            }
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(dataKey.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("UUID", isEqualTo: uuid)
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let document: QueryDocumentSnapshot = snapshot?.documents.first else {
                    completable(.error(FirebaseStoreError.failedToFetch))
                    return
                }
                document.reference.delete { error in
                    if let error {
                        completable(.error(error))
                        return
                    } else {
                        completable(.completed)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    /// 객체 리스트 불러오기
    func fetchList<T: BaseEntity>(dataKey: FirebaseKey.FireStore, queryList: [FirebaseQueryDTO]) -> Single<[T]> {
        Single<[T]>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreError.failedToFetch))
                return Disposables.create()
            }
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseKey.FireStore.users.rawValue)
            guard let query: FirebaseFirestore.Query = self.makeQuery(docRef: docRef, queryList: queryList) else {
                single(.failure(FirebaseStoreError.invalidQuery))
                return Disposables.create()
            }
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let documents: [QueryDocumentSnapshot] = snapshot?.documents else {
                    single(.failure(FirebaseStoreError.failedToFetch))
                    return
                }
                let dataList: [T] = documents.compactMap({ try? T.decode(dictionary: $0.data()) })
                single(.success(dataList))
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Private
    private func makeQuery(docRef: FirebaseFirestore.CollectionReference, queryList: [FirebaseQueryDTO]) -> FirebaseFirestore.Query? {
        guard let firstDTO = queryList.first,
              var query: FirebaseFirestore.Query = firstDTO.queryKey.makeQueryWithDocRef(
                docRef: docRef,
                key: firstDTO.key,
                value: firstDTO.value
              ) else {
            return nil
        }
        let queryListWithoutFirst: [FirebaseQueryDTO] = Array(queryList.dropFirst())
        for dto in queryListWithoutFirst {
            query = makeQuery(queryRef: query, dto: dto)
        }
        return query
    }
    
    private func makeQuery(queryRef: FirebaseFirestore.Query, dto: FirebaseQueryDTO) -> FirebaseFirestore.Query {
        return dto.queryKey.whereField(query: queryRef, key: dto.key, value: dto.value)
    }
}

enum FirebaseStoreError: Error {
    case failedToUpdate
    case failedToCreate
    case failedToFetch
    case failedToDelete
    case invalidQuery
    case invalidUUID
    case alreadyExists
}
