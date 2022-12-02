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
    let showDetailFriend: (String) -> Void
}

protocol FriendListViewModelInput {
    func reload()
    func didSelectItem(userUUID: String)
    func addFriend(uuid: String) -> Completable
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
    
    init(fetchFriendListUseCase: FetchFriendListUseCase, actions: FriendListViewModelActions? = nil) {
        self.fetchFriendListUseCase = fetchFriendListUseCase
        self.actions = actions
        
        self.fetchFriendListUseCase.getFriendsData()
            .subscribe(onSuccess: { [weak self] (model: [Friend]) in
                self?.friendsData.accept(model)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - INPUT
    
    func reload() {
        self.fetchFriendListUseCase.reload()
        
        self.fetchFriendListUseCase.getFriendsData()
            .subscribe(onSuccess: { [weak self] (model: [Friend]) in
                self?.friendsData.accept(model)
            })
            .disposed(by: disposeBag)
    }
    
    func didSelectItem(userUUID: String) {
        print(userUUID)
        self.actions?.showDetailFriend(userUUID)
    }
    
    func addFriend(uuid: String) -> Completable {
        return self.fetchFriendListUseCase.addFriend(uuid: uuid)
    }
    
}
