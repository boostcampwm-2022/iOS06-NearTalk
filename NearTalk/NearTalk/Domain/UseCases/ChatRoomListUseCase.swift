//
//  ChatRoomListUseCase.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation

protocol ChatRoomListUseCase {
    
}

final class DefaultChatRoomListUseCase: ChatRoomListUseCase {
    private let chatRoomListRepository: ChatRoomListRepository!
    
    init(chatRoomListRepository: ChatRoomListRepository) {
        self.chatRoomListRepository = chatRoomListRepository
    }
    
}
