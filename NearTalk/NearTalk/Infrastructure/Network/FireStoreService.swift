//
//  FireStoreService.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/12.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import RxSwift

protocol FireStoreService {
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
final class DefaultFireStoreService: FireStoreService {
    private let db: Firestore
    
    init() {
        self.db = Firestore.firestore()
    }
    
    // MARK: - Private
    private func getUserProfile(email: String) -> Single<UserProfile?> {
        Single<UserProfile?>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreError.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseServiceType.FireStore.users.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("email", isEqualTo: email)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let profile = try? snapshot?.documents.first?.data(as: UserProfile.self) else {
                    single(.failure(FirebaseStoreError.failedToFetchProfile))
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
                single(.failure(FirebaseStoreError.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseServiceType.FireStore.users.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("email", isEqualTo: email)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let document: QueryDocumentSnapshot = snapshot?.documents.first,
                      var currentUserProfile: UserProfile = try? document.data(as: UserProfile.self)  else {
                    single(.failure(FirebaseStoreError.failedToFetchProfile))
                    return
                }
                currentUserProfile = userProfile
                currentUserProfile.email = email // 이메일은 수정할 수 없음 (유저 고유값)
                
                try? document.reference.setData(from: currentUserProfile) { error in
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
                single(.failure(FirebaseStoreError.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseServiceType.FireStore.chatRoom.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("roomID", in: roomIDs)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let documents: [QueryDocumentSnapshot] = snapshot?.documents else {
                    single(.failure(FirebaseStoreError.failedToFetchChatRoom))
                    return
                }
                let roomList: [ChatRoom] = documents.compactMap({ try? $0.data(as: ChatRoom.self) })
                single(.success(roomList))
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - 친구
extension DefaultFireStoreService {
    func addFriend(friendID: String) -> Single<[UserProfile]?> {
        self.getMyProfile()
            .flatMap { [weak self] profile -> Single<UserProfile?> in
                guard let self,
                      var updatedProfile = profile else {
                    return .error(FirebaseStoreError.failedToFetchProfile)
                }
                if let isContained = updatedProfile.friends?.contains(friendID),
                   isContained {
                    return .error(FirebaseStoreError.alreadyExists)
                }
                updatedProfile.friends?.append(friendID)
                return self.updateMyUserProfile(updatedProfile)
            }
            .flatMap { [weak self] profile -> Single<[UserProfile]?> in
                guard let self,
                      let profile,
                      let friendIDs = profile.friends  else {
                    return .error(FirebaseStoreError.failedToFetchProfile)
                }
                return self.getUserProfileList(userIDs: friendIDs)
            }
    }
    
    func removeFriend(friendID: String) -> Single<[UserProfile]?> {
        self.getMyProfile()
            .flatMap { [weak self] profile -> Single<UserProfile?> in
                guard let self,
                      var updatedProfile = profile else {
                    return .error(FirebaseStoreError.failedToFetchProfile)
                }
                if let isContained = updatedProfile.friends?.contains(friendID),
                   !isContained {
                    return .error(FirebaseStoreError.invalidFriend)
                }
                updatedProfile.friends = updatedProfile.friends?.filter({ $0 != friendID })
                return self.updateMyUserProfile(updatedProfile)
            }
            .flatMap { [weak self] profile -> Single<[UserProfile]?> in
                guard let self,
                      let profile,
                      let friendIDs = profile.friends  else {
                    return .error(FirebaseStoreError.failedToFetchProfile)
                }
                return self.getUserProfileList(userIDs: friendIDs)
            }
    }
}

// MARK: - 사용자 데이터
extension DefaultFireStoreService {
    func getMyProfile() -> Single<UserProfile?> {
        Single<String?>.create { single in
            guard let currentUser: FirebaseAuth.User = Auth.auth().currentUser,
                  let email: String = currentUser.email else {
                single(.failure(FirebaseStoreError.invalidUser))
                return Disposables.create()
            }
            single(.success(email))
            return Disposables.create()
        }
        .flatMap { [weak self] email in
            guard let self, let email else {
                return .error(FirebaseStoreError.failedToFetchProfile)
            }
            return self.getUserProfile(email: email)
        }
    }
    
    func getUserProfile(userID: String) -> Single<UserProfile?> {
        Single<UserProfile?>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreError.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseServiceType.FireStore.users.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("userID", isEqualTo: userID)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let profile = try? snapshot?.documents.first?.data(as: UserProfile.self) else {
                    single(.failure(FirebaseStoreError.failedToFetchProfile))
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
                single(.failure(FirebaseStoreError.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseServiceType.FireStore.users.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("userID", in: userIDs)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let documents: [QueryDocumentSnapshot] = snapshot?.documents else {
                    single(.failure(FirebaseStoreError.failedToFetchProfile))
                    return
                }
                let profileList: [UserProfile] = documents.compactMap({ try? $0.data(as: UserProfile.self) })
                single(.success(profileList))
            }
            
            return Disposables.create()
        }
    }
    
    func createUserProfile(_ userProfile: UserProfile) -> Single<UserProfile?> {
        Single<UserProfile?>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreError.failedToCreateProfile))
                return Disposables.create()
            }
            
            do {
                try self.db.collection(FirebaseServiceType.FireStore.users.rawValue).document()
                    .setData(from: userProfile) { err in
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
                    return .error(FirebaseStoreError.failedToUpdateProfile)
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
                single(.failure(FirebaseStoreError.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseServiceType.FireStore.users.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("email", isEqualTo: email)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let document: QueryDocumentSnapshot = snapshot?.documents.first else {
                    single(.failure(FirebaseStoreError.failedToFetchProfile))
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
extension DefaultFireStoreService {
    func enterChatRoom(_ chatRoomID: String) -> Single<Bool> {
        self.getMyProfile()
            .flatMap { [weak self] profile in
                guard let self,
                      var profile else {
                    return .error(FirebaseStoreError.failedToFetchProfile)
                }
                if let alreadyExist = profile.chatRooms?.contains(chatRoomID),
                   alreadyExist {
                    return .error(FirebaseStoreError.alreadyExists)
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
                    return .error(FirebaseStoreError.failedToFetchProfile)
                }
                if let alreadyExist = profile.chatRooms?.contains(chatRoomID),
                   !alreadyExist {
                    return .error(FirebaseStoreError.alreadyExists)
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
                    return .error(FirebaseStoreError.failedToFetchProfile)
                }
                return self.fetchChatRoomList(roomIDs: rooms)
            }
    }
    
    func fetchChatRoom(roomID: String) -> Single<ChatRoom?> {
        Single<ChatRoom?>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreError.invalidUser))
                return Disposables.create()
            }
            
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseServiceType.FireStore.chatRoom.rawValue)
            let query: FirebaseFirestore.Query = docRef.whereField("roomID", isEqualTo: roomID)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let document: QueryDocumentSnapshot = snapshot?.documents.first else {
                    single(.failure(FirebaseStoreError.failedToFetchChatRoom))
                    return
                }
                if let room: ChatRoom = try? document.data(as: ChatRoom.self) {
                    single(.success(room))
                } else {
                    single(.failure(FirebaseStoreError.failedToFetchChatRoom))
                }
            }
            
            return Disposables.create()
        }
    }

    func createChatRoom(room: ChatRoom) -> Single<ChatRoom?> {
        Single<ChatRoom?>.create { [weak self] single in
            guard let self else {
                single(.failure(FirebaseStoreError.failedToCreateChatRoom))
                return Disposables.create()
            }
            
            do {
                try self.db.collection(FirebaseServiceType.FireStore.chatRoom.rawValue).document()
                    .setData(from: room) { err in
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
            let docRef: FirebaseFirestore.CollectionReference = self.db.collection(FirebaseServiceType.FireStore.users.rawValue)
            let query: FirebaseFirestore.Query = docRef
                .whereField("latitude", isGreaterThan: southWest.latitude)
                .whereField("latitude", isLessThan: northEast.latitude)
                .whereField("longitude", isGreaterThan: southWest.longitude)
                .whereField("longitude", isLessThan: northEast.longitude)
            
            query.getDocuments { snapshot, error in
                guard error == nil,
                      let documents: [QueryDocumentSnapshot] = snapshot?.documents else {
                    single(.failure(FirebaseStoreError.failedToFetchChatRoom))
                    return
                }
                let chatRooms: [ChatRoom] = documents.compactMap({ try? $0.data(as: ChatRoom.self) })
                single(.success(chatRooms))
            }

            return Disposables.create()
        }
    }
}

enum FirebaseStoreError: Error {
    case invalidUser
    case alreadyExists
    case invalidFriend
    case failedToUpdateProfile
    case failedToCreateProfile
    case failedToFetchProfile
    case failedToFetchChatRoom
    case failedToCreateChatRoom
}
