//
//  FriendsListViewModel.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation
import RxRelay
import RxSwift

struct FriendListViewModelActions {
    let showDetailFriend: () -> Void
}

protocol FriendListViewModelInput {
    func didSelectItem(at index: Int)
    func addFriend()
}

protocol FriendListViewModelOutput {
    var friendsData: BehaviorRelay<[Friend]> { get }
}

protocol FriendListViewModel: FriendListViewModelInput, FriendListViewModelOutput {}

final class DefaultFriendListViewModel: FriendListViewModel {
    
    private let fetchFriendListUseCase: FetchFriendListUseCase
    private let actions: FriendListViewModelActions?
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - OUTPUT
    var friendsData: BehaviorRelay<[Friend]> = BehaviorRelay<[Friend]>(value: [])
    
    init(useCase: FetchFriendListUseCase, actions: FriendListViewModelActions? = nil) {
        self.fetchFriendListUseCase = useCase
        self.actions = actions
        
        self.fetchFriendListUseCase.getFriendsData()
            .bind(to: self.friendsData)
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - INPUT
    func didSelectItem(at index: Int) {
        
    }
    
    func addFriend() {
        
    }
    
}
