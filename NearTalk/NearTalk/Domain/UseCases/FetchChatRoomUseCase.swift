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
    func getGroupChatListWithCoordinates(southWest: NCLocation, northEast: NCLocation) -> Single<[ChatRoom]>
    func getUserChatRoomTickets() -> Single<[UserChatRoomTicket]>
    func getUserChatRoomTicket(roomID: String) -> Single<UserChatRoomTicket>
    func getUserProfile(userID: String) -> Single<UserProfile>
    func getMyProfile() -> UserProfile?
    func newGetChatRoomUUIDList()
}
final class DefaultFetchChatRoomUseCase: FetchChatRoomUseCase {
    private let disposeBag: DisposeBag = .init()
    private let chatRoomListRepository: ChatRoomListRepository
    private let profileRepository: ProfileRepository
    private let userDefaultsRepository: UserDefaultsRepository
    private var newChatRoomUUIDList: PublishRelay<[String]> = .init()
    
    init(chatRoomListRepository: ChatRoomListRepository, profileRepository: ProfileRepository, userDefaultsRepository: UserDefaultsRepository) {
        self.chatRoomListRepository = chatRoomListRepository
        self.profileRepository = profileRepository
        self.userDefaultsRepository = userDefaultsRepository
        self.newGetChatRoomUUIDList()
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
    
    func getGroupChatListWithCoordinates(southWest: NCLocation, northEast: NCLocation) -> Single<[ChatRoom]> {
        self.chatRoomListRepository.fetchChatRoomListWithCoordinates(southWest: southWest, northEast: northEast)
    }
    
    func getUserChatRoomTickets() -> Single<[UserChatRoomTicket]> {
        self.chatRoomListRepository.fetchUserChatRoomTickets()
    }
    
    func getUserChatRoomTicket(roomID: String) -> Single<UserChatRoomTicket> {
        self.chatRoomListRepository.fetchUserChatRoomTicket(roomID)
    }
    
    func newGetChatRoomUUIDList() {
        self.chatRoomListRepository.fetchUserChatRoomUUIDList()
            .subscribe { [weak self] (uuidList: [String]) in
                guard let self else {
                    return
                }
                self.newChatRoomUUIDList.accept(uuidList)
            }.disposed(by: disposeBag)
    }
    
    func getUserProfile(userID: String) -> Single<UserProfile> {
        return self.profileRepository.fetchProfileByUUID(userID)
    }
    
    func getMyProfile() -> UserProfile? {
        return self.userDefaultsRepository.fetchUserProfile()
    }
    
    // MARK: - Private
    private func newGetChatRoomList() -> Observable<[ChatRoom]> {
        self.newChatRoomUUIDList
            .flatMap { [weak self] (uuidList: [String]) in
                guard let self else {
                    throw FetchChatRoomUseCaseError.failedToFetchRoom
                }
                let fetchChatRoomList: [Observable<ChatRoom>] = uuidList.map {
                    self.chatRoomListRepository.observeChatRoomInfo($0)
                }
                return Observable.combineLatest(fetchChatRoomList)
            }
    }
}
// MARK: - FetchChatRoomUseCaseError
enum FetchChatRoomUseCaseError: Error {
    case failedToFetchRoom
}
