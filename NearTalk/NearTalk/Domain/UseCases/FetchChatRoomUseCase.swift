//
// ChatRoomListUseCase.swift
// NearTalk
//
// Created by 김영욱 on 2022/11/15.
//
import Foundation
import RxCocoa
import RxSwift
protocol FetchChatRoomUseCase {
    func createObservableGroupChatList() -> Observable<[GroupChatRoomListData]>
    func createObservableDMChatList() -> Observable<[DMChatRoomListData]>
    func createUserChatRoomTicket(ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket>
    func createFriendChatRoomTicket(ticket: UserChatRoomTicket, friendID: String) -> Single<UserChatRoomTicket>
    func getGroupChatListWithCoordinates(southWest: NCLocation, northEast: NCLocation) -> Single<[ChatRoom]>
    func getUserChatRoomTickets() -> Single<[UserChatRoomTicket]>
    func getUserChatRoomTicket(roomID: String) -> Single<UserChatRoomTicket>
    func getUserChatRoomTicketList() -> Observable<[UserChatRoomTicket]>
    func getUserProfile(userID: String) -> Single<UserProfile>
    func getMyProfile() -> UserProfile?
    func newGetChatRoomUUIDList()
    func newGetChatRoomList() -> Observable<[ChatRoom]>
    func hasFriendDMChat(myID: String, friendID: String) -> Single<ChatRoom?>

}
final class DefaultFetchChatRoomUseCase: FetchChatRoomUseCase {
    private let disposeBag: DisposeBag = .init()
    private let chatRoomListRepository: ChatRoomListRepository
    private let profileRepository: ProfileRepository
    private let userDefaultsRepository: UserDefaultsRepository
    private var newChatRoomUUIDList: PublishRelay<[String]> = .init()
    private var userTicketList: BehaviorRelay<[UserChatRoomTicket]> = .init(value: [])
    
    init(chatRoomListRepository: ChatRoomListRepository, profileRepository: ProfileRepository, userDefaultsRepository: UserDefaultsRepository) {
        self.chatRoomListRepository = chatRoomListRepository
        self.profileRepository = profileRepository
        self.userDefaultsRepository = userDefaultsRepository
        self.newGetChatRoomUUIDList()
        self.newGetUserTicketList()
    }
    
    func createObservableGroupChatList() -> Observable<[GroupChatRoomListData]> {
        self.newGetChatRoomList()
            .map { $0.filter { $0.roomType == "group" } }
            .map { $0.map { GroupChatRoomListData(data: $0) } }
    }
    
    func createObservableDMChatList() -> Observable<[DMChatRoomListData]> {
        self.newGetChatRoomList()
            .map { $0.filter { $0.roomType == "dm" } }
            .map { $0.map { DMChatRoomListData(data: $0) } }
    }
    
    func hasFriendDMChat(myID: String, friendID: String) -> Single<ChatRoom?> {
        self.chatRoomListRepository.fetchSingleChatRoomList(myID)
            .map { $0.filter { $0.roomType == "dm" } }
            .map {
                $0.filter {
                    guard let userList = $0.userList
                    else {
                        return false
                    }
                    return userList.contains(friendID)
                }
            }
            .map { $0.first }
    }
    
    func getGroupChatListWithCoordinates(southWest: NCLocation, northEast: NCLocation) -> Single<[ChatRoom]> {
        self.chatRoomListRepository.fetchChatRoomListWithCoordinates(southWest: southWest, northEast: northEast)
    }
    
    func getUserChatRoomTickets() -> Single<[UserChatRoomTicket]> {
        self.chatRoomListRepository.fetchUserChatRoomTickets()
    }
    
    func getUserChatRoomTicket(roomID: String) -> Single<UserChatRoomTicket> {
        self.chatRoomListRepository.fetchUserChatRoomTicket(roomID)
    }
    
    func getUserChatRoomTicketList() -> Observable<[UserChatRoomTicket]> {
        return self.chatRoomListRepository.observeUserChatRoomTicketList()
    }
    
    func newGetChatRoomUUIDList() {
        self.chatRoomListRepository.fetchUserChatRoomUUIDList()
            .subscribe { [weak self] (uuidList: [String]) in
                guard let self
                else {
                    return
                }
                self.newChatRoomUUIDList.accept(uuidList)
            }.disposed(by: disposeBag)
    }
    
    func newGetUserTicketList() {
        self.chatRoomListRepository.observeUserChatRoomTicketList()
            .subscribe { [weak self] (list: [UserChatRoomTicket]) in
                guard let self
                else {
                    return
                }
                self.userTicketList.accept(list)
            }.disposed(by: disposeBag)
    }
    
    func getUserProfile(userID: String) -> Single<UserProfile> {
        return self.profileRepository.fetchProfileByUUID(userID)
    }
    
    func getMyProfile() -> UserProfile? {
        return self.userDefaultsRepository.fetchUserProfile()
    }
    
    func createUserChatRoomTicket(ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket> {
        return self.chatRoomListRepository.createUserChatRoomTicket(ticket)
    }
    
    func createFriendChatRoomTicket(ticket: UserChatRoomTicket, friendID: String) -> Single<UserChatRoomTicket> {
        return self.chatRoomListRepository.createFriendChatRoomTicket(ticket, friendID)
    }
    
    // MARK: - Private
    
    func newGetChatRoomList() -> Observable<[ChatRoom]> {
        self.userTicketList
            .flatMap { [weak self] (list: [UserChatRoomTicket]) in
                guard let self
                else {
                    throw FetchChatRoomUseCaseError.failedToFetchRoom
                }
                let fetchChatRoomList: [Observable<ChatRoom>] = list.map {
                    self.chatRoomListRepository.observeChatRoomInfo($0.roomID ?? "")
                }
                return Observable.combineLatest(fetchChatRoomList)
            }
    }
    
}
// MARK: - FetchChatRoomUseCaseError
enum FetchChatRoomUseCaseError: Error {
    case failedToFetchRoom
}
