//
//  FetchFriendListUseCase.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/21.
//

import Foundation
import RxSwift

protocol FetchFriendListUseCase {
    func getFriendsData() -> Observable<[Friend]>
}

final class DefaultFetchFriendListUseCase: FetchFriendListUseCase {

    private let disposeBag = DisposeBag()
    private let profileRepository: ProfileRepository!
    private let frends: Single<[UserProfile]>
    
    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
        self.frends = profileRepository.fetchFriendsProfile()
    }

    func getFriendsData() -> Observable<[Friend]> {
        return self.frends
            .asObservable()
            .map {
                $0.map { Friend(userID: $0.uuid,
                               username: $0.username,
                               statusMessage: $0.statusMessage,
                               profileImagePath: $0.profileImagePath) }
            }
    }
}
