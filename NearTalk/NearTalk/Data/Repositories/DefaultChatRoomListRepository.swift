//
//  ChatRoomListRepository.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation
import RxSwift

final class DefaultChatRoomListRepository {
    
    private let dataTransferService: any StorageService
    private let databaseService: any RealTimeDatabaseService
    private let firestoreService: any FirestoreService
    private let profileRepository: any ProfileRepository
    
    init(
        dataTransferService: any StorageService,
        profileRepository: any ProfileRepository,
        databaseService: any RealTimeDatabaseService,
        firestoreService: any FirestoreService
    ) {
        self.dataTransferService = dataTransferService
        self.profileRepository = profileRepository
        self.databaseService = databaseService
        self.firestoreService = firestoreService
    }
}

extension DefaultChatRoomListRepository: ChatRoomListRepository {    
    func dropUserFromChatRoom(_ userUUID: String, _ roomID: String) -> Completable {
        self.fetchChatRoomInfo(roomID)
            .flatMapCompletable { room in
                self.dropUserFromChatRoom(chatRoom: room, uuid: userUUID)
                    .andThen(self.databaseService.deleteUserTicket(userUUID, roomID))
            }
    }
    
    func dropUserFromChatRoom(chatRoom: ChatRoom, uuid: String) -> Completable {
        var updatingChatRoom: ChatRoom = chatRoom
        updatingChatRoom.userList = chatRoom.userList?.filter { $0 != uuid }
        guard let nextUserList = updatingChatRoom.userList, let roomID = updatingChatRoom.uuid else {
            return Completable.error(ChatRoomListRepositoryError.corruptedChatRoom)
        }
        
        if nextUserList.isEmpty {
            return self.firestoreService
                .delete(data: chatRoom, dataKey: .chatRoom)
                .andThen(self.databaseService
                    .deleteChatRoom(roomID))
                .andThen(self.databaseService
                    .deleteChatMessages(roomID))
        } else {
            return self.firestoreService
                .update(updatedData: updatingChatRoom, dataKey: .chatRoom)
                .asCompletable()
                .andThen(self.databaseService
                    .updateChatRoom(updatingChatRoom)
                    .asCompletable())
        }
    }
    
    func dropUserFromChatRooms() -> Completable {
        self.profileRepository.fetchMyProfile()
            .map { $0.uuid }
            .flatMapCompletable { uuid in
                guard let uuid = uuid
                else {
                    return Completable.error(DefaultProfileRepositoryError.invalidUserProfile)
                }
                return Completable.zip(
                    self.fetchUserChatRoomUUIDList()
                        .asObservable()
                        .flatMap { Observable.from($0) }
                        .flatMap { self.fetchChatRoomInfo($0).asObservable() }
                        .flatMap { self.dropUserFromChatRoom(chatRoom: $0, uuid: uuid).asObservable() }
                        .asCompletable()
                )
                .andThen(self.databaseService.deleteUserTicketList(uuid))
            }
    }

    func createChatRoom(_ chatRoom: ChatRoom) -> Completable {
        Single.zip(
            self.firestoreService.create(data: chatRoom, dataKey: .chatRoom),
            self.databaseService.createChatRoom(chatRoom)
        ).asCompletable()
    }
    
    func fetchChatRoomListWithCoordinates(southWest: NCLocation, northEast: NCLocation) -> Single<[ChatRoom]> {
        let queryList: [FirebaseQueryDTO] = [
            .init(key: "latitude", value: southWest.latitude, queryKey: .isGreaterThan),
            .init(key: "latitude", value: northEast.latitude, queryKey: .isLessThan)
        ]
        return self.firestoreService.fetchList(dataKey: .chatRoom, queryList: queryList)
    }
    
    func fetchUserChatRoomUUIDList() -> Single<[String]> {
        self.profileRepository
            .fetchMyProfile()
            .map { $0.chatRooms ?? [] }
    }
    
    func fetchChatRoomInfo(_ chatRoomID: String) -> Single<ChatRoom> {
        self.databaseService.fetchChatRoomInfo(chatRoomID)
    }
    
    func observeChatRoomInfo(_ chatRoomID: String) -> Observable<ChatRoom> {
        self.databaseService.observeChatRoomInfo(chatRoomID)
    }
    
    // MARK: - UserChatRoomTicket
    func createUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket> {
        self.databaseService.createUserChatRoomTicket(ticket)
    }
    
    func fetchUserChatRoomTickets() -> Single<[UserChatRoomTicket]> {
        self.profileRepository.fetchMyProfile()
            .flatMap { [weak self] (profile: UserProfile) in
                guard let self,
                      let uuid: String = profile.uuid
                else {
                    throw ChatRoomListRepositoryError.failedToFetch
                }
                return self.databaseService.fetchUserChatRoomTicketList(uuid)
            }
    }
    
    func fetchUserChatRoomTicket(_ roomID: String) -> Single<UserChatRoomTicket> {
        self.profileRepository.fetchMyProfile()
            .flatMap { [weak self] (profile: UserProfile) in
                guard let self,
                      let uuid: String = profile.uuid
                else {
                    throw ChatRoomListRepositoryError.failedToFetch
                }
                return self.databaseService.fetchSingleUserChatRoomTicket(uuid, roomID)
            }
    }
    
    func fetchUserChatRoomTicket(_ userUUID: String, _ roomID: String) -> Single<UserChatRoomTicket> {
        self.databaseService.fetchSingleUserChatRoomTicket(userUUID, roomID)
    }
    
    func updateUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket> {
        self.databaseService.updateUserChatRoomTicket(ticket)
    }
    
    func observeUserChatRoomTicketList() -> Observable<[UserChatRoomTicket]> {
        self.profileRepository.fetchMyProfile()
            .asObservable()
            .flatMap { [weak self] (profile: UserProfile) in
                guard let self,
                      let uuid: String = profile.uuid
                else {
                    throw ChatRoomListRepositoryError.failedToFetch
                }
                return self.databaseService.observeUserChatRoomTicketList(uuid)
            }
    }
    
    func observeUserChatRoomTicket(_ userUUID: String, _ roomID: String) -> RxSwift.Observable<UserChatRoomTicket> {
        self.databaseService.observeUserChatRoomTicket(userUUID, roomID)
    }
    
    func fetchSingleChatRoomList(_ userID: String) -> Single<[ChatRoom]> {
        self.databaseService.fetchUserChatRoomTicketList(userID)
            .flatMap { [weak self] (ticketList: [UserChatRoomTicket]) in
                guard let self
                else {
                    throw FetchChatRoomUseCaseError.failedToFetchRoom
                }
                let fetchChatRoomList: [Single<ChatRoom>] = ticketList.map {
                    self.fetchChatRoomInfo($0.roomID ?? "")
                }
                
                return Single.zip(fetchChatRoomList)
            }
    }
}

enum ChatRoomListRepositoryError: Error {
    case failedToFetch
    case failedToCrate
    case corruptedChatRoom
}
