//
//  AccessibleChatRoomsRepository.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/24.
//

import Foundation
import RxSwift

protocol AccessibleChatRoomsRepository {
    func fetchAccessibleAllChatRooms(in region: NCMapRegion) -> Single<[ChatRoom]>
    func fetchAccessibleGroupChatRooms(in region: NCMapRegion) -> Single<[GroupChatRoomListData]>
    func fetchAccessibleDMChatRooms(in region: NCMapRegion) -> Single<[DMChatRoomListData]>
    func fetchDummyChatRooms() -> Single<[ChatRoom]>
}
