//
//  AccessibleChatRoomsRepositoryTests.swift
//  NearTalkTests
//
//  Created by 고병학 on 2022/12/08.
//

import RxSwift
import XCTest

final class AccessibleChatRoomsRepositoryTests: XCTestCase {

    private let firestoreService: FirestoreService = DefaultFirestoreService()
    private let storageService: StorageService = DefaultStorageService()
    
    private lazy var accessibleChatRoomsRepository: AccessibleChatRoomsRepository = DefaultAccessibleChatRoomsRepository(dependencies: .init(
        firestoreService: self.firestoreService,
        apiDataTransferService: self.storageService,
        imageDataTransferService: self.storageService
    ))
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_좌표기준_채팅방_불러오기() async throws {
        let fetch: Single<[ChatRoom]> = self.accessibleChatRoomsRepository.fetchAccessibleAllChatRooms(in: .init(
            centerLocation: .init(latitude: 37.3625102546472, longitude: 127.1043696800272),
            latitudeDelta: 100,
            longitudeDelta: 1000
        ))
        
        let result: [ChatRoom] = try await fetch.value
        
        print(result.count)
    }

}
