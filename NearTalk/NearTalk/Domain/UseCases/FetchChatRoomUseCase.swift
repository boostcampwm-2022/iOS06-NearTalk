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
    //    func getGroupChatListCoreData() -> Observable<[GroupChatRoomListData]>
    //    func getDataOfDMChatCoreData() -> Observable<[DMChatRoomListData]>
    
    func getGroupChatList() -> Observable<[GroupChatRoomListData]>
    func getDMChatList() -> Observable<[DMChatRoomListData]>

    func newObserveGroupChatList() -> Observable<[GroupChatRoomListData]>
    func newObserveDMChatList() -> Observable<[DMChatRoomListData]>
    func getGroupChatListWithCoordinates(southWest: NCLocation, northEast: NCLocation) -> Single<[ChatRoom]>
    func getUserChatRoomTickets() -> Single<[UserChatRoomTicket]>
}

final class DefaultFetchChatRoomUseCase: FetchChatRoomUseCase {

    private let disposeBag: DisposeBag = .init()
    private let chatRoomListRepository: ChatRoomListRepository
    private let chatRoom: Observable<[ChatRoom]>
    private let userChatRoomModel: Observable<[UserChatRoomModel]>
    
    private var newChatRoomUUIDList: PublishRelay<[String]> = .init()
    private lazy var newChatRoom: Observable<[ChatRoom]> = self.newGetChatRoomList()
    
    init(chatRoomListRepository: ChatRoomListRepository) {
        self.chatRoomListRepository = chatRoomListRepository
        
        self.chatRoom = self.chatRoomListRepository.fetchChatRoomList()
        self.userChatRoomModel = self.chatRoomListRepository.fetchUserChatRoomModel()
        
        self.newGetChatRoomUUIDList()
    }
    
    func getGroupChatList() -> Observable<[GroupChatRoomListData]> {
        return self.chatRoom
            .asObservable()
            .map { $0.filter { $0.roomType == "group" } }
            .map { $0.map { GroupChatRoomListData(data: $0) } }
    }
    
    func getDMChatList() -> Observable<[DMChatRoomListData]> {
        return self.chatRoom
            .asObservable()
            .map { $0.filter { $0.roomType == "dm" } }
            .map { $0.map { DMChatRoomListData(data: $0) } }
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
    
    private func newGetChatRoomUUIDList() {
        self.chatRoomListRepository.fetchUserChatRoomUUIDList()
            .subscribe { [weak self] (uuidList: [String]) in
                guard let self else {
                    return
                }
                self.newChatRoomUUIDList.accept(uuidList)
            }.disposed(by: disposeBag)
    }
}

// MARK: - FetchChatRoomUseCaseError
enum FetchChatRoomUseCaseError: Error {
    case failedToFetchRoom
}
