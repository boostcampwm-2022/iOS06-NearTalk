//
//  ChatRoomListRepository.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation
import RxSwift

final class DefaultChatRoomListRepository {
    
    private let dataTransferService: StorageService

    init(dataTransferService: StorageService) {
        self.dataTransferService = dataTransferService
    }
}

extension DefaultChatRoomListRepository: ChatRoomListRepository {
    // func fetchChatRoomList() { }
}
