//
//  UploadChatRoomInfoUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/21.
//

import Foundation

import RxSwift

protocol UploadChatRoomInfoUseCase {
    func uploadChatRoom(_ userID: String)
}

final class DefaultUploadChatRoomInfoUseCase: UploadChatRoomInfoUseCase {
    
    // TODO: - repository 주임
    init() {
        
    }
    
    func uploadChatRoom(_ userID: String) {
        print(#function)
        // TODO: - repository 이용해서 친구 삭제
        // 1. 이미 생성된 채팅방이 있으면 채팅방 보여준다
        // 2. 없으면 생성
    }
}
