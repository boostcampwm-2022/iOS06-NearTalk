//
//  RootTabBarViewModel.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import Foundation
import RxRelay
import RxSwift

protocol RootTabBarViewModel {
    var messageAllCount: BehaviorRelay<Int> { get }
    var readMessageCount: BehaviorRelay<Int> { get }
}

final class DefaultRootTabBarViewModel: RootTabBarViewModel {
    private let disposeBag: DisposeBag = .init()
    private let chatRoomListUseCase: FetchChatRoomUseCase!
    var messageAllCount = BehaviorRelay<Int>(value: 0)
    var readMessageCount = BehaviorRelay<Int>(value: 0)
    
    init(useCase: FetchChatRoomUseCase) {
        self.chatRoomListUseCase = useCase
        
        self.chatRoomListUseCase.newGetChatRoomList()
            .subscribe(onNext: { (list: [ChatRoom]) in
                let count = list.reduce(0) { $0 + ($1.messageCount ?? 0) }
                self.messageAllCount.accept(count)
            })
            .disposed(by: self.disposeBag)
        
        self.chatRoomListUseCase.getUserChatRoomTicketList()
            .subscribe(onNext: { (userTicketList: [UserChatRoomTicket]) in
                let count = userTicketList.reduce(0) { $0 + ($1.lastRoomMessageCount ?? 0) }
                self.readMessageCount.accept(count)
            })
            .disposed(by: self.disposeBag)
    }
}
