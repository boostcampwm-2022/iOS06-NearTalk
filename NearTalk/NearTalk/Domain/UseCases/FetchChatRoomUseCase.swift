//
//  ChatRoomListUseCase.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation
import RxCocoa
import RxSwift

protocol FetchChatRoomUseCase {
    func newObserveGroupChatList() -> Observable<[GroupChatRoomListData]>
    func newObserveDMChatList() -> Observable<[DMChatRoomListData]>
    func getGroupChatListWithCoordinates(southWest: NCLocation, northEast: NCLocation) -> Single<[ChatRoom]>
    func getUserChatRoomTickets() -> Single<[UserChatRoomTicket]>
    func getUserChatRoomTicket(roomID: String) -> Single<UserChatRoomTicket>
    func newGetChatRoomUUIDList()
}

final class DefaultFetchChatRoomUseCase: FetchChatRoomUseCase {
    
    private let disposeBag: DisposeBag = .init()
    private let chatRoomListRepository: ChatRoomListRepository
    
    private var newChatRoomUUIDList: BehaviorRelay<[String]> = BehaviorRelay<[String]>(value: [])
    private lazy var newChatRoom: Observable<[ChatRoom]> = self.newGetChatRoomList()
    
    init(chatRoomListRepository: ChatRoomListRepository) {
        self.chatRoomListRepository = chatRoomListRepository
        self.newGetChatRoomUUIDList()
    }
    
    func newObserveGroupChatList() -> Observable<[GroupChatRoomListData]> {
        self.newChatRoom
            .map { $0.filter { $0.roomType == "group" } }
            .map { $0.map { GroupChatRoomListData(data: $0) } }
    }
    
    func newObserveDMChatList() -> Observable<[DMChatRoomListData]> {
        self.newChatRoom
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
    
    // MARK: - Private
    private func newGetChatRoomList() -> Observable<[ChatRoom]> {
        self.newChatRoomUUIDList
            .flatMap { [weak self] (uuidList: [String]) in
                guard let self else {
                    throw FetchChatRoomUseCaseError.failedToFetchRoom
                }
                
                // Test
                let dummyUUID = ["21578E2D-AC38-4BA1-8B85-7A38C8D473F6"]
                
                let fetchChatRoomList: [Observable<ChatRoom>] = dummyUUID.map {
                    self.chatRoomListRepository.observeChatRoomInfo($0)
                }
                return Observable.combineLatest(fetchChatRoomList)
            }
    }
    
    private func newGetChatRoomUUIDList() {
        self.chatRoomListRepository.fetchUserChatRoomUUIDList()
            .subscribe { [weak self] (uuidList: [String]) in
                guard let self else {
                    return
                }
                
                // Test
                let dummyUUID = ["21578E2D-AC38-4BA1-8B85-7A38C8D473F6"]
                
                self.newChatRoomUUIDList.accept(dummyUUID)
            }.disposed(by: disposeBag)
    }
}

// MARK: - FetchChatRoomUseCaseError
enum FetchChatRoomUseCaseError: Error {
    case failedToFetchRoom
}
