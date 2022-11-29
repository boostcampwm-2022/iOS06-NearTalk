//
//  ChatRoomListRepository.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation
import RxSwift

protocol ChatRoomListRepository {
    
    // fireBase 채팅방 목록 가져오기
    func fetchChatRoomList() -> Observable<[ChatRoom]>
    func fetchUserChatRoomModel() -> Observable<[UserChatRoomModel]>
    
    func createChatRoom(_ chatRoom: ChatRoom) -> Completable
    func fetchChatRoomListWithCoordinates(southWest: NCLocation, northEast: NCLocation) -> Single<[ChatRoom]>
    func fetchChatRoomInfo(_ chatRoomID: String) -> Single<ChatRoom>
    func observeChatRoomInfo(_ chatRoomID: String) -> Observable<ChatRoom>
    func fetchUserChatRoomUUIDList() -> Single<[String]>
    
    func fetchUserChatRoomTickets() -> Single<[UserChatRoomTicket]>
    func updateUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Completable
}
