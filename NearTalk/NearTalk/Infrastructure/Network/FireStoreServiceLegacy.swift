//
//  FireStoreService.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/12.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import RxSwift

protocol FireStoreServiceLegacy {
    // 사용자 프로필
    func getMyProfile() -> Single<UserProfile?>
    func getUserProfile(userID: String) -> Single<UserProfile?>
    func getUserProfileList(userIDs: [String]) -> Single<[UserProfile]?>
    func createUserProfile(_ userProfile: UserProfile) -> Single<UserProfile?>
    func updateMyUserProfile(_ userProfile: UserProfile) -> Single<UserProfile?>
    func deleteUserProfile() -> Single<Bool>
    
    // 친구
    func addFriend(friendID: String) -> Single<[UserProfile]?>
    func removeFriend(friendID: String) -> Single<[UserProfile]?>
    
    // 채팅방
    func createChatRoom(room: ChatRoom) -> Single<ChatRoom?>
    func getAvailableChatRooms(southWest: NCLocation, northEast: NCLocation) -> Single<[ChatRoom]?>
    func fetchMyChatRooms() -> Single<[ChatRoom]?>
    func fetchChatRoom(roomID: String) -> Single<ChatRoom?>
    func enterChatRoom(_ chatRoomID: String) -> Single<Bool>
    func leaveChatRoom(_ chatRoomID: String) -> Single<Bool>
}

/// FireStore에 데이터 읽기/쓰기를 관리하는 서비스
final class DefaultFireStoreServiceLegacy: FireStoreServiceLegacy {
    private let db: Firestore
    
    init() {
        self.db = Firestore.firestore()
    }
    
    // MARK: - Private
    private func getUserProfile(email: String) -> Single<UserProfile?> {
        Single<UserProfile?>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreErrorLegacy.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseKey.FireStore.users.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("email", isEqualTo: email)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let dictionary: [String: Any] = snapshot?.documents.first?.data(),
                      let profile: UserProfile = try? UserProfile.decode(dictionary: dictionary) else {
                    single(.failure(FirebaseStoreErrorLegacy.failedToFetchProfile))
                    return
                }
                single(.success(profile))
            }

            return Disposables.create()
        }
    }
    
    private func updateUserProfile(_ userProfile: UserProfile) -> Single<UserProfile?> {
        Single<UserProfile?>.create { [weak self] single in
            guard let self,
                  let email = userProfile.email else {
                single(.failure(FirebaseStoreErrorLegacy.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseKey.FireStore.users.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("email", isEqualTo: email)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let document: QueryDocumentSnapshot = snapshot?.documents.first,
                      var currentUserProfile: UserProfile = try? UserProfile.decode(dictionary: document.data()) else {
                    single(.failure(FirebaseStoreErrorLegacy.failedToFetchProfile))
                    return
                }
                currentUserProfile = userProfile
                currentUserProfile.email = email // 이메일은 수정할 수 없음 (유저 고유값)
                
                try? document.reference.setData(currentUserProfile.encode()) { error in
                    if let error {
                        single(.failure(error))
                    } else {
                        single(.success(currentUserProfile))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    private func fetchChatRoomList(roomIDs: [String]) -> Single<[ChatRoom]?> {
        Single<[ChatRoom]?>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreErrorLegacy.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseKey.FireStore.chatRoom.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("roomID", in: roomIDs)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let documents: [QueryDocumentSnapshot] = snapshot?.documents else {
                    single(.failure(FirebaseStoreErrorLegacy.failedToFetchChatRoom))
                    return
                }
                let roomList: [ChatRoom] = documents.compactMap {
                    try? ChatRoom.decode(dictionary: $0.data())
                }
                single(.success(roomList))
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - 친구
extension DefaultFireStoreServiceLegacy {
    func addFriend(friendID: String) -> Single<[UserProfile]?> {
        self.getMyProfile()
            .flatMap { [weak self] profile -> Single<UserProfile?> in
                guard let self,
                      var updatedProfile = profile else {
                    return .error(FirebaseStoreErrorLegacy.failedToFetchProfile)
                }
                if let isContained = updatedProfile.friends?.contains(friendID),
                   isContained {
                    return .error(FirebaseStoreErrorLegacy.alreadyExists)
                }
                updatedProfile.friends?.append(friendID)
                return self.updateMyUserProfile(updatedProfile)
            }
            .flatMap { [weak self] profile -> Single<[UserProfile]?> in
                guard let self,
                      let profile,
                      let friendIDs = profile.friends  else {
                    return .error(FirebaseStoreErrorLegacy.failedToFetchProfile)
                }
                return self.getUserProfileList(userIDs: friendIDs)
            }
    }
    
    func removeFriend(friendID: String) -> Single<[UserProfile]?> {
        self.getMyProfile()
            .flatMap { [weak self] profile -> Single<UserProfile?> in
                guard let self,
                      var updatedProfile = profile else {
                    return .error(FirebaseStoreErrorLegacy.failedToFetchProfile)
                }
                if let isContained = updatedProfile.friends?.contains(friendID),
                   !isContained {
                    return .error(FirebaseStoreErrorLegacy.invalidFriend)
                }
                updatedProfile.friends = updatedProfile.friends?.filter({ $0 != friendID })
                return self.updateMyUserProfile(updatedProfile)
            }
            .flatMap { [weak self] profile -> Single<[UserProfile]?> in
                guard let self,
                      let profile,
                      let friendIDs = profile.friends  else {
                    return .error(FirebaseStoreErrorLegacy.failedToFetchProfile)
                }
                return self.getUserProfileList(userIDs: friendIDs)
            }
    }
}

// MARK: - 사용자 데이터
extension DefaultFireStoreServiceLegacy {
    func getMyProfile() -> Single<UserProfile?> {
        Single<String>.create { single in
            guard let currentUser: FirebaseAuth.User = Auth.auth().currentUser,
                  let email: String = currentUser.email else {
                single(.failure(FirebaseStoreErrorLegacy.invalidUser))
                return Disposables.create()
            }
            single(.success(email))
            return Disposables.create()
        }
        .flatMap { self.getUserProfile(email: $0) }
    }
    
    func getUserProfile(userID: String) -> Single<UserProfile?> {
        Single<UserProfile?>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreErrorLegacy.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseKey.FireStore.users.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("userID", isEqualTo: userID)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let dictionary: [String: Any] = snapshot?.documents.first?.data(),
                      let profile: UserProfile = try? UserProfile.decode(dictionary: dictionary) else {
                    single(.failure(FirebaseStoreErrorLegacy.failedToFetchProfile))
                    return
                }
                single(.success(profile))
            }

            return Disposables.create()
        }
    }
    
    func getUserProfileList(userIDs: [String]) -> Single<[UserProfile]?> {
        Single<[UserProfile]?>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreErrorLegacy.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseKey.FireStore.users.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("userID", in: userIDs)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let documents: [QueryDocumentSnapshot] = snapshot?.documents else {
                    single(.failure(FirebaseStoreErrorLegacy.failedToFetchProfile))
                    return
                }
                let profileList: [UserProfile] = documents.compactMap {
                    try? UserProfile.decode(dictionary: $0.data())
                }
                single(.success(profileList))
            }
            
            return Disposables.create()
        }
    }
    
    func createUserProfile(_ userProfile: UserProfile) -> Single<UserProfile?> {
        Single<UserProfile?>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreErrorLegacy.failedToCreateProfile))
                return Disposables.create()
            }
            
            do {
                try self.db.collection(FirebaseKey.FireStore.users.rawValue).document()
                    .setData(userProfile.encode()) { err in
                        if let err {
                            single(.failure(err))
                        } else {
                            single(.success(userProfile))
                        }
                    }
            } catch let error {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }
    
    /// 현재 유저의 프로필 업데이트
    func updateMyUserProfile(_ userProfile: UserProfile) -> Single<UserProfile?> {
        self.getMyProfile()
            .flatMap { [weak self] profile -> Single<UserProfile?> in
                guard let self,
                      let email = profile?.email else {
                    return .error(FirebaseStoreErrorLegacy.failedToUpdateProfile)
                }
                var newProfile = userProfile
                newProfile.email = email
                return self.updateUserProfile(newProfile)
            }
    }
    
    /// 현재 유저의 프로필 삭제
    func deleteUserProfile() -> Single<Bool> {
        Single<Bool>.create { [weak self] single in
            guard let self,
                  let currentUser: FirebaseAuth.User = Auth.auth().currentUser,
                  let email = currentUser.email else {
                single(.failure(FirebaseStoreErrorLegacy.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseKey.FireStore.users.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("email", isEqualTo: email)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let document: QueryDocumentSnapshot = snapshot?.documents.first else {
                    single(.failure(FirebaseStoreErrorLegacy.failedToFetchProfile))
                    return
                }
                
                document.reference.delete { error in
                    if let error {
                        single(.failure(error))
                        return
                    } else {
                        single(.success(true))
                    }
                }
            }

            return Disposables.create()
        }
    }
}

// MARK: - 채팅방
extension DefaultFireStoreServiceLegacy {
    func enterChatRoom(_ chatRoomID: String) -> Single<Bool> {
        self.getMyProfile()
            .flatMap { [weak self] profile in
                guard let self,
                      var profile else {
                    return .error(FirebaseStoreErrorLegacy.failedToFetchProfile)
                }
                if let alreadyExist = profile.chatRooms?.contains(chatRoomID),
                   alreadyExist {
                    return .error(FirebaseStoreErrorLegacy.alreadyExists)
                }
                profile.chatRooms?.append(chatRoomID)
                return self.updateUserProfile(profile)
                    .map { $0 != nil }
            }
    }
    
    func leaveChatRoom(_ chatRoomID: String) -> Single<Bool> {
        self.getMyProfile()
            .flatMap { [weak self] profile in
                guard let self,
                      var profile else {
                    return .error(FirebaseStoreErrorLegacy.failedToFetchProfile)
                }
                if let alreadyExist = profile.chatRooms?.contains(chatRoomID),
                   !alreadyExist {
                    return .error(FirebaseStoreErrorLegacy.alreadyExists)
                }
                profile.chatRooms = profile.chatRooms?.filter({ $0 != chatRoomID })
                return self.updateUserProfile(profile)
                    .map { $0 != nil }
            }
    }
    
    func fetchMyChatRooms() -> Single<[ChatRoom]?> {
        self.getMyProfile()
            .flatMap { [weak self] profile in
                guard let self,
                      let profile,
                      let rooms = profile.chatRooms else {
                    return .error(FirebaseStoreErrorLegacy.failedToFetchProfile)
                }
                return self.fetchChatRoomList(roomIDs: rooms)
            }
    }
    
    func fetchChatRoom(roomID: String) -> Single<ChatRoom?> {
        Single<ChatRoom?>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreErrorLegacy.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseKey.FireStore.chatRoom.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("roomID", isEqualTo: roomID)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let document: QueryDocumentSnapshot = snapshot?.documents.first else {
                    single(.failure(FirebaseStoreErrorLegacy.failedToFetchChatRoom))
                    return
                }
                if let room: ChatRoom = try? ChatRoom.decode(dictionary: document.data()) {
                    single(.success(room))
                } else {
                    single(.failure(FirebaseStoreErrorLegacy.failedToFetchChatRoom))
                }
            }
            
            return Disposables.create()
        }
    }

    func createChatRoom(room: ChatRoom) -> Single<ChatRoom?> {
        Single<ChatRoom?>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreErrorLegacy.failedToCreateChatRoom))
                return Disposables.create()
            }
            
            do {
                try self.db.collection(FirebaseKey.FireStore.chatRoom.rawValue).document()
                    .setData(room.encode()) { err in
                        if let err {
                            single(.failure(err))
                        } else {
                            single(.success(room))
                        }
                    }
            } catch let error {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }
    
    func getAvailableChatRooms(southWest: NCLocation, northEast: NCLocation) -> Single<[ChatRoom]?> {
        Single<[ChatRoom]?>.create { [weak self] single in
            guard let self else {
                return Disposables.create()
            }
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseKey.FireStore.users.rawValue)
            let query: FirebaseFirestore.Query = docRef
                .whereField("latitude", isGreaterThan: southWest.latitude)
                .whereField("latitude", isLessThan: northEast.latitude)
                .whereField("longitude", isGreaterThan: southWest.longitude)
                .whereField("longitude", isLessThan: northEast.longitude)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let documents: [QueryDocumentSnapshot] = snapshot?.documents else {
                    single(.failure(FirebaseStoreErrorLegacy.failedToFetchChatRoom))
                    return
                }
                let chatRooms: [ChatRoom] = documents.compactMap {
                    try? ChatRoom.decode(dictionary: $0.data())
                }
                single(.success(chatRooms))
            }

            return Disposables.create()
        }
    }
}

enum FirebaseStoreErrorLegacy: Error {
    case invalidUser
    case alreadyExists
    case invalidFriend
    case failedToUpdateProfile
    case failedToCreateProfile
    case failedToFetchProfile
    case failedToFetchChatRoom
    case failedToCreateChatRoom
}
