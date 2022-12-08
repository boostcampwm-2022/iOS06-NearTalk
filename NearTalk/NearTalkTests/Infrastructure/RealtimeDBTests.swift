//
//  FirebaseTests.swift
//  NearTalkTests
//
//  Created by 고병학 on 2022/12/08.
//

import RxBlocking
import RxSwift
import XCTest

final class RealtimeDBTests: XCTestCase {
    
    private let realtimeDB: RealTimeDatabaseService = DefaultRealTimeDatabaseService()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_최근메세지_10개_가져오기() throws {
        let pageCount: Int = 10
        let roomID: String = "81D881F7-D25C-41DC-AA1A-4EC38530B201" // 서버에 있는 채팅방 ID 필요
        let date: Date = Date() // 불러오고 싶은 기준 시간
        
        let fetchMessage: Single<[ChatMessage]> = self.realtimeDB.fetchMessages(date: date, pageCount: pageCount, roomID: roomID)
        let result: [ChatMessage] = try fetchMessage.toBlocking().first()!
        print("🚧 result.count", result.count)
        
        result.forEach { message in
            print("- ", Date(timeIntervalSince1970: message.createdAtTimeStamp!), message.uuid!, message.text!)
        }
        XCTAssert(result.count <= pageCount)
    }
}
