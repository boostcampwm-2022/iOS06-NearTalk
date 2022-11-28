//
//  FetchAccessibleChatRoomsUseCase.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/24.
//

import Foundation
import RxSwift

protocol FetchAccessibleChatRoomsUseCase {
    func fetchAccessibleAllChatRooms(in region: NCMapRegion) -> Observable<[ChatRoom]>
    func fetchAccessibleGroupChatRooms(in region: NCMapRegion) -> Observable<[GroupChatRoomListData]>
    func fetchAccessibleDMChatRooms(in region: NCMapRegion) -> Observable<[DMChatRoomListData]>
}

final class DefaultFetchAccessibleChatRoomsUseCase: FetchAccessibleChatRoomsUseCase {
    
    struct Repositories {
        let accessibleChatRoomsRepository: AccessibleChatRoomsRepository
    }
    
    private let repositories: Repositories
    
    init(repositories: Repositories) {
        self.repositories = repositories
    }
    
    func fetchAccessibleAllChatRooms(in region: NCMapRegion) -> Observable<[ChatRoom]> {
        return self.repositories.accessibleChatRoomsRepository
            .fetchAccessibleAllChatRooms(in: region)
            .asObservable()
    }
    
    func fetchAccessibleGroupChatRooms(in region: NCMapRegion) -> Observable<[GroupChatRoomListData]> {
        return self.repositories.accessibleChatRoomsRepository
            .fetchAccessibleGroupChatRooms(in: region)
            .asObservable()
    }
    
    func fetchAccessibleDMChatRooms(in region: NCMapRegion) -> Observable<[DMChatRoomListData]> {
        return self.repositories.accessibleChatRoomsRepository
            .fetchAccessibleDMChatRooms(in: region)
            .asObservable()
    }
}
