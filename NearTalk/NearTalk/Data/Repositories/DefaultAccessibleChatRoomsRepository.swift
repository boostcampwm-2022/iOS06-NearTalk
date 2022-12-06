//
//  DefaultAccessibleChatRoomsRepository.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/24.
//

import Foundation
import RxSwift

final class DefaultAccessibleChatRoomsRepository {
    
    struct Dependencies {
        let firestoreService: FirestoreService
        let apiDataTransferService: StorageService
        let imageDataTransferService: StorageService
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}

extension DefaultAccessibleChatRoomsRepository: AccessibleChatRoomsRepository {
    
    func fetchAccessibleAllChatRooms(in region: NCMapRegion) -> Single<[ChatRoom]> {
        let centerLocation = region.centerLocation
        let southWest = centerLocation.add(longitudeDelta: -(region.longitudeDelta / 2), latitudeDelta: -(region.latitudeDelta / 2))
        let northEast = centerLocation.add(longitudeDelta: region.longitudeDelta / 2, latitudeDelta: region.latitudeDelta / 2)

        let service = self.dependencies.firestoreService
        let queryList: [FirebaseQueryDTO] = [
            .init(key: "latitude", value: southWest.latitude, queryKey: .isGreaterThan),
            .init(key: "latitude", value: northEast.latitude, queryKey: .isLessThan)
        ]
        let latitudeFilteredChatRooms: Single<[ChatRoom]> = service.fetchList(dataKey: .chatRoom, queryList: queryList)
        
        return latitudeFilteredChatRooms
            .map {
                $0.filter {
                    guard let chatRoomLongitude = $0.location?.longitude
                    else { return false }
                    
                    return southWest.longitude < chatRoomLongitude && chatRoomLongitude < northEast.longitude
                }
            }
    }
    
    func fetchAccessibleGroupChatRooms(in region: NCMapRegion) -> Single<[GroupChatRoomListData]> {
        return self.fetchAccessibleAllChatRooms(in: region)
        .map { $0.filter { $0.roomType == "group" } }
        .map { $0.map { GroupChatRoomListData(data: $0) } }
    }
    
    func fetchAccessibleDMChatRooms(in region: NCMapRegion) -> Single<[DMChatRoomListData]> {
        return self.fetchAccessibleAllChatRooms(in: region)
        .map { $0.filter { $0.roomType == "dm" } }
        .map { $0.map { DMChatRoomListData(data: $0) } }
    }
    
    // 더미
    func fetchDummyChatRooms() -> Single<[ChatRoom]> {
        let dummyChatRooms: [ChatRoom] = [
            ChatRoom(uuid: "1",
                     userList: [],
                     roomImagePath: nil,
                     roomType: "group",
                     roomName: "1번방",
                     roomDescription: "1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다1번방 입니다",
                     location: NCLocation(latitude: 37.32, longitude: 127.091),
                     accessibleRadius: 1,
                     recentMessageID: nil,
                     recentMessageText: nil,
                     recentMessageDate: nil,
                     maxNumberOfParticipants: nil,
                     messageCount: nil),
            ChatRoom(uuid: "2",
                     userList: [],
                     roomImagePath: nil,
                     roomType: "group",
                     roomName: "2번방",
                     roomDescription: "2번방 입니다",
                     location: NCLocation(latitude: 37.324, longitude: 127.0912),
                     accessibleRadius: 2,
                     recentMessageID: nil,
                     recentMessageText: nil,
                     recentMessageDate: nil,
                     maxNumberOfParticipants: nil,
                     messageCount: nil),
            ChatRoom(uuid: "3",
                     userList: [],
                     roomImagePath: nil,
                     roomType: "group",
                     roomName: "3번방",
                     roomDescription: "3번방 입니다",
                     location: NCLocation(latitude: 37.325, longitude: 127.0913),
                     accessibleRadius: 3,
                     recentMessageID: nil,
                     recentMessageText: nil,
                     recentMessageDate: nil,
                     maxNumberOfParticipants: nil,
                     messageCount: nil),
            ChatRoom(uuid: "4",
                     userList: [],
                     roomImagePath: nil,
                     roomType: "dm",
                     roomName: "4번방",
                     roomDescription: "4번방 입니다",
                     location: NCLocation(latitude: 37.321, longitude: 127.0911),
                     accessibleRadius: 4,
                     recentMessageID: nil,
                     recentMessageText: nil,
                     recentMessageDate: nil,
                     maxNumberOfParticipants: nil,
                     messageCount: nil),
            ChatRoom(uuid: "5",
                     userList: [],
                     roomImagePath: nil,
                     roomType: "dm",
                     roomName: "5번방",
                     roomDescription: "5번방 입니다",
                     location: NCLocation(latitude: 37.323, longitude: 127.0913),
                     accessibleRadius: 5,
                     recentMessageID: nil,
                     recentMessageText: nil,
                     recentMessageDate: nil,
                     maxNumberOfParticipants: nil,
                     messageCount: nil)
            ]

        return Single.just(dummyChatRooms)
    }
}
