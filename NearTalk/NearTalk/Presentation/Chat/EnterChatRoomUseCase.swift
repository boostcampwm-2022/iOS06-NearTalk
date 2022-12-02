//
//  EnterChatRoomUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/12/02.
//

import Foundation
import RxSwift

protocol EnterChatRoomUseCase {
    func enterChatRoom(userID: String, chatRoom: ChatRoom) -> Single<UserChatRoomTicket>
    func upateUserChatRoomTicket(ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket>
}

final class DefaultEnterChatRoomUseCase: EnterChatRoomUseCase {
    
    private let chatRoomListRepository: ChatRoomListRepository
    private let profileRepository: ProfileRepository
    
    init(chatRoomListRepository: ChatRoomListRepository,
         profileRepository: ProfileRepository
    ) {
        self.chatRoomListRepository = chatRoomListRepository
        self.profileRepository = profileRepository
    }
    
    private func createUserChatRoomTicket(ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket> {
        return self.chatRoomListRepository.createUserChatRoomTicket(ticket)
    }
    
    func upateUserChatRoomTicket(ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket> {
        return self.chatRoomListRepository.updateUserChatRoomTicket(ticket)
    }
    
    func enterChatRoom(userID: String, chatRoom: ChatRoom) -> Single<UserChatRoomTicket> {
        print(#function)
        guard let roomID = chatRoom.uuid else {
            return .error(EnterChatRoomUseCaseError.faildToEnter)
        }
        
        return self.fetchUserChatRoomTicket(roomID: roomID)
            .debug()
            .flatMap { userChatRoomTicket in
                var newUserChatRoomTicket = userChatRoomTicket
                newUserChatRoomTicket.lastReadMessageID = chatRoom.recentMessageID
                newUserChatRoomTicket.lastRoomMessageCount = chatRoom.messageCount
                return self.upateUserChatRoomTicket(ticket: newUserChatRoomTicket)
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
    
    private func fetchUserChatRoomTicket(roomID: String) -> Single<UserChatRoomTicket> {
        return self.chatRoomListRepository.fetchUserChatRoomTicket(roomID)
    }
}

enum EnterChatRoomUseCaseError: Error {
    case faildToEnter
}
