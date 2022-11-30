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
        
        let queryList: [FirebaseQueryDTO] = [
            .init(key: "latitude", value: southWest.latitude, queryKey: .isGreaterThan),
            .init(key: "latitude", value: northEast.latitude, queryKey: .isLessThan)
        ]
        
        let service = self.dependencies.firestoreService
        let latitudeFilteredChatRooms = service.fetchList(dataKey: .chatRoom, queryList: queryList) as Single<[ChatRoom]>
        
        return latitudeFilteredChatRooms
            .map {
                $0.filter {
                    guard let chatRoomLongitude = $0.location?.longitude else {
                        return false
                    }
                    
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
        .map { $0.filter { $0.roomType == "group" } }
        .map { $0.map { DMChatRoomListData(data: $0) } }
    }
}
