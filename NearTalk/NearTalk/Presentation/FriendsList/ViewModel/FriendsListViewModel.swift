//
//  FriendsListViewModel.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import Foundation
import RxRelay
import RxSwift

struct FriendistViewModelActions {
    let showDetailFriend: () -> Void
}

protocol FriendListViewModelInput {
    func didSelectItem(at index: Int)
    func addFriendButton()
}

protocol FriendListViewModelOutput {
    var friendListData: BehaviorRelay<[String]> { get }
}

protocol FriendListViewModel: FriendListViewModelInput, FriendListViewModelOutput {}

final class FriendsListViewModel: FriendListViewModel {
    
    private let friendListUseCase: FetchFriendListUseCase
    private let actions: FriendistViewModelActions?
    private let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - OUTPUT
    var friendListData: RxRelay.BehaviorRelay<[String]>
    
    init() {
        
    }
    
    // MARK: - INPUT
    func didSelectItem(at index: Int) {
        
    }
    
    func addFriendButton() {
        
    }
    
//    private func createDummyData() {
//        friendsListDummyData.append(FriendsListModel(img: "", name: "Ronald Robertson", description: "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum."))
//        friendsListDummyData.append(FriendsListModel(img: "", name: "Johnny Watson", description: "Reprehenderit mollit excepteur labore deserunt officia laboris eiusmod cillum eu duis"))
//        friendsListDummyData.append(FriendsListModel(img: "", name: "Annette Cooper", description: "Aliqua mollit nisi incididunt id eu consequat eu cupidatat."))
//        friendsListDummyData.append(FriendsListModel(img: "", name: "Arthur Bell", description: "Voluptate irure aliquip consectetur commodo ex ex."))
//        friendsListDummyData.append(FriendsListModel(img: "", name: "Jane Warren", description: "Ex Lorem veniam veniam irure sunt adipisicing culpa."))
//        friendsListDummyData.append(FriendsListModel(img: "", name: "Morris Henry", description: "Dolore veniam Lorem occaecat veniam irure laborum est amet."))
//        friendsListDummyData.append(FriendsListModel(img: "", name: "Irma Flores", description: "Amet enim do laborum tempor nisi aliqua ad adipisicing."))
//        friendsListDummyData.append(FriendsListModel(img: "", name: "008", description: "qwer"))
//        friendsListDummyData.append(FriendsListModel(img: "", name: "009", description: "asdf"))
//        friendsListDummyData.append(FriendsListModel(img: "", name: "010", description: "zxcv"))
//
//    }
}
