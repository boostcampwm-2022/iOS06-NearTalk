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
        let radiusDistanceMeters = region.radiusDistanceMeters
        let latitudinalMeters = region.latitudinalMeters
        let longitudinalMeters = region.longitudinalMeters
        
        let southWest = centerLocation.add(longitudeMeters: -longitudinalMeters / 2, latitudeMeters: -latitudinalMeters / 2)
        let northEast = centerLocation.add(longitudeMeters: longitudinalMeters / 2, latitudeMeters: latitudinalMeters / 2)
        
        let queryList: [FirebaseQueryDTO] = [
            .init(key: "latitude", value: southWest.latitude, queryKey: .isGreaterThan),
            .init(key: "latitude", value: northEast.latitude, queryKey: .isLessThan),
            .init(key: "longitude", value: southWest.latitude, queryKey: .isGreaterThan),
            .init(key: "longitude", value: northEast.latitude, queryKey: .isLessThan)
        ]
        
        return self.dependencies.firestoreService.fetchList(dataKey: .chatRoom, queryList: queryList)
            .map {
                $0.filter {
                    if let chatRoomLocation = $0.location {
                        return centerLocation.distance(from: chatRoomLocation) <= radiusDistanceMeters
                    }
                    return false
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
