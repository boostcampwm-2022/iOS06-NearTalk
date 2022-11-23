//
//  UploadChatRoomInfoUseCase.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/23.
//

import Foundation
import RxSwift

protocol UploadChatRoomInfoUseCase {
    /// 이미지 업로드 후 파이어베이스 스토리지 경로를 반환한다.
    func uploadImage(_ imageData: Data) -> Single<String>
    func createChatRoom(_ chatRoom: ChatRoom) -> Completable
}

final class DefaultUploadChatRoomInfoUseCase: UploadChatRoomInfoUseCase {
    private let mediaRepository: MediaRepository
    private let chatRoomRepository: ChatRoomListRepository
    
    init(mediaRepository: MediaRepository, chatRoomRepository: ChatRoomListRepository) {
        self.mediaRepository = mediaRepository
        self.chatRoomRepository = chatRoomRepository
    }
    
    func uploadImage(_ imageData: Data) -> Single<String> {
        self.mediaRepository.uploadImage(imageData)
    }
    
    func createChatRoom(_ chatRoom: ChatRoom) -> Completable {
        self.chatRoomRepository.createChatRoom(chatRoom)
    }
}
