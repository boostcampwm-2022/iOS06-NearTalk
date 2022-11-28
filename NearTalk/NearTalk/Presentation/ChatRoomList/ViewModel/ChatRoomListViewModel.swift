//
//  ChatRoomListViewModel.swift
//  NearTalk
//
//  Created by yw22 on 2022/11/11.
//
 
import Foundation
import RxRelay
import RxSwift

struct ChatRoomListViewModelActions {
    let showChatRoom: (String, String) -> Void
    let showCreateChatRoom: () -> Void
    let showDMChatRoomList: () -> Void
    let showGroupChatRoomList: () -> Void
}

protocol ChatRoomListViewModelInput {
    func didDMChatRoomList()
    func didGroupChatRoomList()
    func didCreateChatRoom()
    func didSelectItem(at index: Int)
}

protocol ChatRoomListViewModelOutput {
    func getRecentMessage(messageID: String, roomID: String) -> Single<ChatMessage>
    var groupChatRoomData: BehaviorRelay<[GroupChatRoomListData]> { get }
    var dmChatRoomData: BehaviorRelay<[DMChatRoomListData]> { get }
}

protocol ChatRoomListViewModel: ChatRoomListViewModelInput, ChatRoomListViewModelOutput {}

final class DefaultChatRoomListViewModel: ChatRoomListViewModel {

    private let chatRoomListUseCase: FetchChatRoomUseCase
    private let actions: ChatRoomListViewModelActions?
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - Output
    var groupChatRoomData: BehaviorRelay<[GroupChatRoomListData]> = BehaviorRelay<[GroupChatRoomListData]>(value: [])
    var dmChatRoomData: BehaviorRelay<[DMChatRoomListData]> = BehaviorRelay<[DMChatRoomListData]>(value: [])
    
    init(useCase: FetchChatRoomUseCase, actions: ChatRoomListViewModelActions? = nil) {
        self.chatRoomListUseCase = useCase
        self.actions = actions
        
        self.chatRoomListUseCase.getGroupChatList()
            .bind(to: groupChatRoomData)
            .disposed(by: self.disposeBag)
        
        self.chatRoomListUseCase.getDMChatList()
            .bind(to: dmChatRoomData)
            .disposed(by: self.disposeBag)
        
    }
    
    func getRecentMessage(messageID: String, roomID: String) -> Single<ChatMessage> {
        return self.chatRoomListUseCase.getRecentMessage(messageID: messageID, roomID: roomID)
    }
}

// MARK: - Input
extension DefaultChatRoomListViewModel {
    func didDMChatRoomList() {
        actions?.showDMChatRoomList()
    }
    
    func didGroupChatRoomList() {
        actions?.showGroupChatRoomList()
    }
    
    // 채팅방 클릭시 채팅방 이동
    func didSelectItem(at index: Int) {
        // TODO: - chatRoomID, chatRoomName가 들어가야 함, 수정 필요
        actions?.showChatRoom("chatRoomID", "chatRoomName")
    }
    
    // 체팅방 생성 클릭시 이동
    func didCreateChatRoom() {
        actions?.showCreateChatRoom()
    }
}
