//
//  ChattingRoomListUseCase.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation

protocol ChattingRoomListUseCase {
    
}

final class DefaultChattingRoomListUseCase: ChattingRoomListUseCase {
    private let chattingRoomListRepository: ChattingRoomListRepository!
    
    init(chattingRoomListRepository: ChattingRoomListRepository) {
        self.chattingRoomListRepository = chattingRoomListRepository
    }
    
}
