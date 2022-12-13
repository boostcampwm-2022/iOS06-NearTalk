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
            .subscribe(onNext: { list in
                var count = 0
                list.forEach { count += $0.messageCount ?? 0 }
                self.messageAllCount.accept(count)
            })
            .disposed(by: self.disposeBag)
        
        self.chatRoomListUseCase.getUserChatRoomTicketList()
            .subscribe(onNext: { (userTicketList: [UserChatRoomTicket]) in
                var count = 0
                userTicketList.forEach { count += $0.lastRoomMessageCount ?? 0 }
                self.readMessageCount.accept(count)
            })
            .disposed(by: disposeBag)
    }
}
