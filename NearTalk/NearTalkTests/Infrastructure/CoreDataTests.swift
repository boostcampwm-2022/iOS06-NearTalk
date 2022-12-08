//
//  CoreDataTests.swift
//  NearTalkTests
//
//  Created by 고병학 on 2022/12/05.
//

import Foundation

import RxSwift
import XCTest

final class CoreDataTests: XCTestCase {
    
    private let disposeBag: DisposeBag = .init()
    private let testRoomID: String = "TEST_ROOM_ID"
    private let senderID: String = "SENDER"
    private let coreDataService: DefaultCoreDataService = .init()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_save_message() async {
        print("🟢 " , Self.self, #function)
        let message: ChatMessage = .init(
            uuid: "TEST_MESSAGE_ID",
            chatRoomID: self.testRoomID,
            senderID: self.senderID,
            text: "TEST_MESSAGE_TEXT",
            messageType: "group",
            mediaPath: "",
            mediaType: "",
            createdAtTimeStamp: Date().timeIntervalSince1970
        )
        let fetchMessageList: Single<[ChatMessage]> = self.coreDataService.saveMessage(message)
            .andThen(self.coreDataService.fetchMessageList(roomID: testRoomID, before: Date()))
        do {
            let count = try await fetchMessageList.value.count
            XCTAssertEqual(count, 1)
        } catch let error {
            print(error)
            XCTFail()
        }
    }

    func test_fetch_messages() async throws {
        print("🟢 " , Self.self, #function)
        let fetchMessageList: Single<[ChatMessage]> = self.coreDataService.fetchMessageList(roomID: testRoomID, before: Date())
        do {
            let count = try await fetchMessageList.value.count
            XCTAssertEqual(count, 0)
        } catch let error {
            print(error)
            XCTFail()
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
