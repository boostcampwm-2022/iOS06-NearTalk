//
//  ChatRoomListUseCase.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation
import RxSwift

protocol ChatRoomListUseCase {
    //    func getOpenChatListCoreData() -> Observable<[OpenChatRoomListData]>
    //    func getDataOfDMChatCoreData() -> Observable<[DMChatRoomListData]>
    
        func getOpenChatList() -> Observable<[OpenChatRoomListData]>
        func getDMChatList() -> Observable<[DMChatRoomListData]>
}

final class DefaultChatRoomListUseCase: ChatRoomListUseCase {

    private let disposeBag = DisposeBag()
    private let chatRoomListRepository: ChatRoomListRepository!
    private let chatRoom: Observable<[ChatRoom]>
    private let userChatRoomModel: Observable<[UserChatRoomModel]>
    
    init(chatRoomListRepository: ChatRoomListRepository) {
        self.chatRoomListRepository = chatRoomListRepository
        
        self.chatRoom = self.chatRoomListRepository.fetchChatRoomList()
        self.userChatRoomModel = self.chatRoomListRepository.fetchUserChatRoomModel()
    }
    
    func getOpenChatList() -> Observable<[OpenChatRoomListData]> {
        return self.chatRoom
            .asObservable()
            .map { $0.filter { $0.roomType == "open" } }
            .map { $0.map { OpenChatRoomListData(data: $0) } }
    }
    
    func getDMChatList() -> Observable<[DMChatRoomListData]> {
        return self.chatRoom
            .asObservable()
            .map { $0.filter { $0.roomType == "dm" } }
            .map { $0.map { DMChatRoomListData(data: $0) } }
    }
    
}
