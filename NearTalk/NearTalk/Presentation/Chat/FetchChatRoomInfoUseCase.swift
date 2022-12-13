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
    func fetchParticipantTickets(_ roomID: String) -> Observable<[UserChatRoomTicket]>
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
    
    func fetchParticipantTickets(_ roomID: String) -> Observable<[UserChatRoomTicket]> {
        self.chatRoomListRepository
            .observeChatRoomInfo(roomID)
            .flatMap { (chatRoom: ChatRoom) in
                guard let userList = chatRoom.userList else {
                    return Observable<[UserChatRoomTicket]>.error(FetchChatRoomInfoUseCaseError.failedToFetchUserList)
                }
                let fetchTickets: [Single<UserChatRoomTicket>] = userList.map {
                    self.chatRoomListRepository.fetchUserChatRoomTicket($0, roomID)
                }
                return Single.zip(fetchTickets).asObservable()
            }
    }
}

enum FetchChatRoomInfoUseCaseError: Error {
    case failedToFetchUserList
}
