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
    let showChatRoom: () -> Void
    let showCreateChatRoom: () -> Void
}

protocol ChatRoomListViewModelInput {
    func didCreateChatRoom()
    func didSelectItem(at index: Int)
    func load()
}

protocol ChatRoomListViewModelOutput {
    var openChatRoomData: BehaviorRelay<[OpenChatRoomListData]> { get }
    var dmChatRoomData: BehaviorRelay<[DMChatRoomListData]> { get }
}

protocol ChatRoomListViewModel: ChatRoomListViewModelInput, ChatRoomListViewModelOutput {}

final class DefaultChatRoomListViewModel: ChatRoomListViewModel {

    private let chatRoomListUseCase: ChatRoomListUseCase
    private let actions: ChatRoomListViewModelActions?
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - Output
    var openChatRoomData: BehaviorRelay<[OpenChatRoomListData]> = BehaviorRelay<[OpenChatRoomListData]>(value: [])
    var dmChatRoomData: BehaviorRelay<[DMChatRoomListData]> = BehaviorRelay<[DMChatRoomListData]>(value: [])
    
    init(useCase: ChatRoomListUseCase, actions: ChatRoomListViewModelActions? = nil) {
        self.chatRoomListUseCase = useCase
        self.actions = actions
        
        load()
    }
    
    func load() {
        self.chatRoomListUseCase.getOpenChatList()
            .bind(to: openChatRoomData)
            .disposed(by: self.disposeBag)
        
        self.chatRoomListUseCase.getDMChatList()
            .bind(to: dmChatRoomData)
            .disposed(by: self.disposeBag)
    }
}

// MARK: - Input
extension DefaultChatRoomListViewModel {
    func didCreateChatRoom() {
        actions?.showCreateChatRoom()
    }
    
    func didSelectItem(at index: Int) {
        actions?.showChatRoom()
    }
}
