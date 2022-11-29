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
    private(set) var dummyData: ChatRoomDummyData = ChatRoomDummyData()
    
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
    func createChatRoom(_ chatRoom: ChatRoom) -> Completable {
        Single.zip(
            self.firestoreService.create(data: chatRoom, dataKey: .chatRoom),
            self.databaseService.createChatRoom(chatRoom)
        ).asCompletable()
    }
    
    func fetchChatRoomListWithCoordinates(southWest: NCLocation, northEast: NCLocation) -> Single<[ChatRoom]> {
        let queryList: [FirebaseQueryDTO] = [
            .init(key: "latitude", value: southWest.latitude, queryKey: .isGreaterThan),
            .init(key: "latitude", value: northEast.latitude, queryKey: .isLessThan),
            .init(key: "longitude", value: southWest.longitude, queryKey: .isGreaterThan),
            .init(key: "longitude", value: northEast.longitude, queryKey: .isLessThan)
        ]
        return self.firestoreService.fetchList(dataKey: .chatRoom, queryList: queryList)
    }
    
    func fetchUserChatRoomUUIDList() -> Single<[String]> {
        self.profileRepository
            .fetchMyProfile()
            .flatMap { [weak self] (profile: UserProfile) in
                guard let self,
                      let uuid: String = profile.uuid else {
                    throw ChatRoomListRepositoryError.failedToFetch
                }
                return self.databaseService.fetchUserChatRoomTicketList(uuid)
            }
            .asObservable()
            .map { (tickets: [UserChatRoomTicket]) in
                return tickets.compactMap({ $0.roomID })
            }.asSingle()
    }
    
    func fetchChatRoomInfo(_ chatRoomID: String) -> Single<ChatRoom> {
        self.databaseService.fetchChatRoomInfo(chatRoomID)
    }
    
    func observeChatRoomInfo(_ chatRoomID: String) -> Observable<ChatRoom> {
        self.databaseService.observeChatRoomInfo(chatRoomID)
    }
    
    func fetchUserChatRoomTickets() -> Single<[UserChatRoomTicket]> {
        self.profileRepository.fetchMyProfile()
            .flatMap { [weak self] (profile: UserProfile) in
                guard let self,
                      let uuid: String = profile.uuid else {
                    throw ChatRoomListRepositoryError.failedToFetch
                }
                return self.databaseService.fetchUserChatRoomTicketList(uuid)
            }
    }
    
    func fetchUserChatRoomTicket(_ roomID: String) -> Single<UserChatRoomTicket> {
        self.profileRepository.fetchMyProfile()
            .flatMap { [weak self] (profile: UserProfile) in
                guard let self,
                      let uuid: String = profile.uuid else {
                    throw ChatRoomListRepositoryError.failedToFetch
                }
                return self.databaseService.fetchSingleUserChatRoomTicket(uuid, roomID)
            }
    }
    
    func updateUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Completable {
        self.databaseService.updateUserChatRoomTicket(ticket)
    }
    
    func fetchChatRoomList() -> Observable<[ChatRoom]> {
        return Observable<[ChatRoom]>.create { observer in
            observer.onNext(self.dummyData.chatRoomData)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func fetchUserChatRoomModel() -> Observable<[UserChatRoomModel]> {
        return Observable<[UserChatRoomModel]>.create { observer in
            observer.onNext(self.dummyData.userChatRoomData)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
}

struct ChatRoomDummyData {
    var chatRoomData: [ChatRoom] = []
    var userChatRoomData: [UserChatRoomModel] = []
    
    init() {
        chatRoomData.append(ChatRoom(uuid: "1", userList: ["s001", "s002", "s003", "s004", "s005"], roomType: "group", roomName: "네이버", roomDescription: "술기운이 올라오니"))
        chatRoomData.append(ChatRoom(uuid: "2", userList: ["s001", "s002", "s003", "s005"], roomType: "group", roomName: "다음", roomDescription: "사내놈들끼린 결국엔 여자 얘기"))
        chatRoomData.append(ChatRoom(uuid: "3", userList: ["s001", "s002", "s003", "s004", "s005"], roomType: "group", roomName: "카카오", roomDescription: "적적해서 서로의 전화기를 꺼내"))
        chatRoomData.append(ChatRoom(uuid: "4", userList: ["s001", "s004", "s005"], roomType: "group", roomName: "넷마블", roomDescription: "번호목록을 뒤져보지"))
        chatRoomData.append(ChatRoom(uuid: "5", userList: ["s001", "s002", "s003", "s004", "s005", "s011", "s013", "s014", "s015"], roomType: "group", roomName: "넥슨", roomDescription: "너는 지금 뭐해 자니 밖이야?"))
        chatRoomData.append(ChatRoom(uuid: "6", userList: ["s001", "s009", "s007", "s014", "s021"], roomType: "group", roomName: "엔씨", roomDescription: "뜬금없는 문자를 돌려보지 난"))
        chatRoomData.append(ChatRoom(uuid: "7", userList: ["s001", "s017"], roomType: "group", roomName: "구글", roomDescription: "어떻게 해볼까란 뜻은 아니야"))
        chatRoomData.append(ChatRoom(uuid: "7", userList: ["s001", "s017", "s022"], roomType: "group", roomName: "아마존", roomDescription: "그냥 심심해서 그래 아니 외로워서 그래"))
        
        chatRoomData.append(ChatRoom(uuid: "8", userList: ["s001", "s002"], roomType: "dm", roomName: "라이언", roomDescription: "일 끝나서 친구들과 한잔"))
        chatRoomData.append(ChatRoom(uuid: "9", userList: ["s001", "s002"], roomType: "dm", roomName: "어피치", roomDescription: "내일은 노는 토요일이니깐"))
        chatRoomData.append(ChatRoom(uuid: "10", userList: ["s001", "s002"], roomType: "dm", roomName: "네오", roomDescription: "일 얘기 사는 얘기 재미난 얘기 시간가는 줄 모르는 이 밤"))
        chatRoomData.append(ChatRoom(uuid: "11", userList: ["s001", "s002"], roomType: "dm", roomName: "튜브", roomDescription: "술기운이 올라오니 사내놈들끼린 결국엔 여자 얘기 적적해서 서로의 전화기를 꺼내 번호목록을 뒤져보지"))
        chatRoomData.append(ChatRoom(uuid: "12", userList: ["s001", "s002"], roomType: "dm", roomName: "테스트", roomDescription: "너는 지금 뭐해, 자니, 밖이야? 뜬금없는 문자를 돌려보지 난 어떻게 해볼까란 뜻은 아니야 그냥 심심해서 그래 아니 외로워서 그래"))
        
        userChatRoomData.append(UserChatRoomModel(userID: "s001", chatRoomID: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]))
    }
}

enum ChatRoomListRepositoryError: Error {
    case failedToFetch
    case failedToCrate
}
