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
    var myUUID: String? { get }
}

protocol FriendListViewModel: FriendListViewModelInput, FriendListViewModelOutput {}

final class DefaultFriendListViewModel: FriendListViewModel {
    
    private let userDefaultsUseCase: UserDefaultUseCase
    private let fetchFriendListUseCase: FetchFriendListUseCase
    private let actions: FriendListViewModelActions?
    private let disposeBag: DisposeBag = DisposeBag()
    
    var myUUID: String? { self.userDefaultsUseCase.fetchUserUUID() }
    
    // MARK: - OUTPUT
    var friendsData: BehaviorRelay<[Friend]> = BehaviorRelay<[Friend]>(value: [])
    
    init(
        userDefaultsUseCase: UserDefaultUseCase,
        fetchFriendListUseCase: FetchFriendListUseCase,
        actions: FriendListViewModelActions? = nil
    ) {
        self.userDefaultsUseCase = userDefaultsUseCase
        self.fetchFriendListUseCase = fetchFriendListUseCase
        self.actions = actions
        
        self.fetchFriendListUseCase.getFriendsData()
            .subscribe(onSuccess: { [weak self] (model: [Friend]) in
                self?.friendsData.accept(model)
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - INPUT
    func reload() {
        self.fetchFriendListUseCase.reload()
        
        self.fetchFriendListUseCase.getFriendsData()
            .subscribe(onSuccess: { [weak self] (model: [Friend]) in
                self?.friendsData.accept(model)
            })
            .disposed(by: self.disposeBag)
    }
    
    func didSelectItem(userUUID: String) {
        print(userUUID)
        self.actions?.showDetailFriend(userUUID)
    }
    
    func addFriend(uuid: String) -> Completable {
        return self.fetchFriendListUseCase.addFriend(uuid: uuid)
    }
    
}
