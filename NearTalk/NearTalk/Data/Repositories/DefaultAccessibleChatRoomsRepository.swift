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
                    guard let chatRoomLongitude = $0.location?.longitude else { return false }
                    
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
            ChatRoom(location: NCLocation(longitude: 127.091, latitude: 37.32)),
            ChatRoom(location: NCLocation(longitude: 127.0911, latitude: 37.321)),
            ChatRoom(location: NCLocation(longitude: 127.0912, latitude: 37.322)),
            ChatRoom(location: NCLocation(longitude: 127.092, latitude: 37.33)),
            ChatRoom(location: NCLocation(longitude: 127.093, latitude: 37.34)),
            ChatRoom(location: NCLocation(longitude: 127.094, latitude: 37.35)),
            ChatRoom(location: NCLocation(longitude: 127.095, latitude: 37.36)),
            ChatRoom(location: NCLocation(longitude: 127.0951, latitude: 37.36)),
            ChatRoom(location: NCLocation(longitude: 127.0952, latitude: 37.36)),
            ChatRoom(location: NCLocation(longitude: 127.0953, latitude: 37.36))
        ]
        
        return Single.just(dummyChatRooms)
    }
}
