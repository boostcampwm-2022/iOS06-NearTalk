//
//  ChatRoomListUseCase.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation
import RxSwift

protocol FetchChatRoomUseCase {
    //    func getGroupChatListCoreData() -> Observable<[GroupChatRoomListData]>
    //    func getDataOfDMChatCoreData() -> Observable<[DMChatRoomListData]>
    
        func getGroupChatList() -> Observable<[GroupChatRoomListData]>
        func getDMChatList() -> Observable<[DMChatRoomListData]>
}

final class DefaultFetchChatRoomUseCase: FetchChatRoomUseCase {

    private let disposeBag = DisposeBag()
    private let chatRoomListRepository: ChatRoomListRepository!
    private let chatRoom: Observable<[ChatRoom]>
    private let userChatRoomModel: Observable<[UserChatRoomModel]>
    
    init(chatRoomListRepository: ChatRoomListRepository) {
        self.chatRoomListRepository = chatRoomListRepository
        
        self.chatRoom = self.chatRoomListRepository.fetchChatRoomList()
        self.userChatRoomModel = self.chatRoomListRepository.fetchUserChatRoomModel()
    }
    
    func getGroupChatList() -> Observable<[GroupChatRoomListData]> {
        return self.chatRoom
            .asObservable()
            .map { $0.filter { $0.roomType == "group" } }
            .map { $0.map { GroupChatRoomListData(data: $0) } }
    }
    
    func getDMChatList() -> Observable<[DMChatRoomListData]> {
        return self.chatRoom
            .asObservable()
            .map { $0.filter { $0.roomType == "dm" } }
            .map { $0.map { DMChatRoomListData(data: $0) } }
    }
    
}
