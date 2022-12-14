//
//  EnterChatRoomUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/12/02.
//

import Foundation
import RxSwift

protocol EnterChatRoomUseCase {
    /// 티켓 업데이트
    func updateUserChatRoomTicket(ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket>
    
    /// 티켓 업데이트 (티켓이 없을 경우 생성한다.)
    func configureUserChatRoomTicket(userID: String, chatRoom: ChatRoom) -> Single<UserChatRoomTicket>
    
    /// 모든 참가자의 티켓 가져오기
//    func fetchSingleUserChatRoomTickets(userIDList: [String], chatRoomID: String) -> Single<[UserChatRoomTicket]>
    func fetchSingleUserChatRoomTickets(userIDList: String, chatRoomID: String) -> Single<UserChatRoomTicket>
}

final class DefaultEnterChatRoomUseCase: EnterChatRoomUseCase {
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let chatRoomListRepository: ChatRoomListRepository
    private let profileRepository: ProfileRepository
    
    init(
        chatRoomListRepository: ChatRoomListRepository,
        profileRepository: ProfileRepository
    ) {
        self.chatRoomListRepository = chatRoomListRepository
        self.profileRepository = profileRepository
    }
    
    /// 티켓 업데이트
    func updateUserChatRoomTicket(ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket> {
        return self.chatRoomListRepository.updateUserChatRoomTicket(ticket)
    }
    
    /// 티켓 업데이트 (티켓이 없을 경우 생성한다.)
    func configureUserChatRoomTicket(userID: String, chatRoom: ChatRoom) -> Single<UserChatRoomTicket> {
        guard let roomID = chatRoom.uuid
        else {
            return .error(EnterChatRoomUseCaseError.faildToEnter)
        }
        
        return self.fetchUserChatRoomTicket(roomID: roomID)
            .flatMap { userChatRoomTicket in
                var newUserChatRoomTicket = userChatRoomTicket
                newUserChatRoomTicket.lastReadMessageID = chatRoom.recentMessageID
                newUserChatRoomTicket.lastRoomMessageCount = chatRoom.messageCount
                return self.updateUserChatRoomTicket(ticket: newUserChatRoomTicket)
            }
            .catch { _ in
                let userChatRoomTicket = UserChatRoomTicket(
                    uuid: UUID().uuidString,
                    userID: userID,
                    roomID: roomID,
                    lastReadMessageID: chatRoom.recentMessageID,
                    lastRoomMessageCount: chatRoom.messageCount
                )
                return self.createUserChatRoomTicket(ticket: userChatRoomTicket)
            }
    }
    
//    func fetchSingleUserChatRoomTickets(userIDList: [String], chatRoomID: String) -> Single<[UserChatRoomTicket]> {
//        var userChatRoomTicketList: [UserChatRoomTicket] = []
//
//        return self.fetchSingleUserChatRoomTickets(userIDList: <#T##[String]#>, chatRoomID: <#T##String#>)
//    }
    
    func fetchSingleUserChatRoomTickets(userIDList: String, chatRoomID: String) -> Single<UserChatRoomTicket> {
        self.chatRoomListRepository.fetchUserChatRoomTicket(userIDList, chatRoomID)
    }
    
    // MARK: - Private
    private func createUserChatRoomTicket(ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket> {
        return self.chatRoomListRepository.createUserChatRoomTicket(ticket)
    }
    
    private func fetchUserChatRoomTicket(roomID: String) -> Single<UserChatRoomTicket> {
        return self.chatRoomListRepository.fetchUserChatRoomTicket(roomID)
    }
}

enum EnterChatRoomUseCaseError: Error {
    case faildToEnter
    case failedToFetchUserTicket
}
