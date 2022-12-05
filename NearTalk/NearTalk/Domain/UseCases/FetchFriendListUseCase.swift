//
//  FetchFriendListUseCase.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/21.
//

import Foundation
import RxSwift

protocol FetchFriendListUseCase {
    func reload()
    func getFriendsData() -> Single<[Friend]>
    func addFriend(uuid: String) -> Completable
}

final class DefaultFetchFriendListUseCase: FetchFriendListUseCase {
    
    private let disposeBag = DisposeBag()
    private let profileRepository: ProfileRepository!
    private lazy var frends: Single<[Friend]> = self.getFriendsData()
    
    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }
    
    func reload() {
        self.frends = self.profileRepository.fetchFriendsProfile()
            .map { $0.map { Friend(userID: $0.uuid,
                                   username: $0.username,
                                   statusMessage: $0.statusMessage,
                                   profileImagePath: $0.profileImagePath) } }
    }
    
    func getFriendsData() -> Single<[Friend]> {
        return self.profileRepository.fetchFriendsProfile()
            .map { $0.map { Friend(userID: $0.uuid,
                                   username: $0.username,
                                   statusMessage: $0.statusMessage,
                                   profileImagePath: $0.profileImagePath) } }
    }
    
    func addFriend(uuid: String) -> Completable {
        return self.profileRepository.addFriend(uuid)
    }
}
