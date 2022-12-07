//
//  ChatRoomListRepository.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation
import RxSwift

protocol ChatRoomListRepository {
    func createChatRoom(_ chatRoom: ChatRoom) -> Completable
    func fetchChatRoomListWithCoordinates(southWest: NCLocation, northEast: NCLocation) -> Single<[ChatRoom]>
    func fetchChatRoomInfo(_ chatRoomID: String) -> Single<ChatRoom>
    func observeChatRoomInfo(_ chatRoomID: String) -> Observable<ChatRoom>
    func fetchUserChatRoomUUIDList() -> Single<[String]>
    
    #warning("TicketRepository로 추출")
    func createUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket>
    func fetchUserChatRoomTickets() -> Single<[UserChatRoomTicket]>
    func fetchUserChatRoomTicket(_ roomID: String) -> Single<UserChatRoomTicket>
    func updateUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket>
    func observeUserChatRoomTicketList() -> Observable<UserChatRoomTicket>
}
