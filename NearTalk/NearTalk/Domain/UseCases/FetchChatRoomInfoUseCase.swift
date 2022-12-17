//
//  FetchChatRoomInfoUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/29.
//

import Foundation
import RxSwift

protocol FetchChatRoomInfoUseCase {
    func fetchChatRoomInfo(chatRoomID: String) -> Single<ChatRoom>
    func observeChatRoomInfo(chatRoomID: String) -> Observable<ChatRoom>
    func fetchParticipantTickets(_ room: ChatRoom) -> Observable<[UserChatRoomTicket]>
}

final class DefaultFetchChatRoomInfoUseCase: FetchChatRoomInfoUseCase {
    
    // MARK: - Propotry
    
    private let chatRoomListRepository: ChatRoomListRepository
    
    // MARK: - LifeCycle
    
    init(chatRoomListRepository: ChatRoomListRepository) {
        self.chatRoomListRepository = chatRoomListRepository
    }
    
    func fetchChatRoomInfo(chatRoomID: String) -> Single<ChatRoom> {
        return chatRoomListRepository.fetchChatRoomInfo(chatRoomID)
    }
    
    func observeChatRoomInfo(chatRoomID: String) -> Observable<ChatRoom> {
        return chatRoomListRepository.observeChatRoomInfo(chatRoomID)
    }
    
    func fetchParticipantTickets(_ room: ChatRoom) -> Observable<[UserChatRoomTicket]> {
        guard let userList = room.userList,
              let roomID = room.uuid else {
            return .error(FetchChatRoomInfoUseCaseError.failedToFetchUserList)
        }
        let fetchTickets: [Observable<UserChatRoomTicket>] = userList.map {
            self.chatRoomListRepository.observeUserChatRoomTicket($0, roomID)
        }
        return Observable.combineLatest(fetchTickets)
    }
}

enum FetchChatRoomInfoUseCaseError: Error {
    case failedToFetchUserList
}
