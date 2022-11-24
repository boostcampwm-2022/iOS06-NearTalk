//
//  AccessibleChatRoomsRepository.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/24.
//

import Foundation
import RxSwift

protocol AccessibleChatRoomsRepository {
    func fetchAccessibleAllChatRooms(centerLocation: NCLocation,
                                     radiusDistance: Double,
                                     latitudinalMeters: Double,
                                     longitudinalMeters: Double) -> Single<[ChatRoom]>
    
    func fetchAccessibleGroupChatRooms(centerLocation: NCLocation,
                                       radiusDistance: Double,
                                       latitudinalMeters: Double,
                                       longitudinalMeters: Double) -> Single<[GroupChatRoomListData]>
    
    func fetchAccessibleDMChatRooms(centerLocation: NCLocation,
                                    radiusDistance: Double,
                                    latitudinalMeters: Double,
                                    longitudinalMeters: Double) -> Single<[DMChatRoomListData]>
}
