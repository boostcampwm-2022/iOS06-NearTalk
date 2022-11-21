//
//  FetchFriendListUseCase.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/21.
//

import Foundation
import RxSwift

protocol FetchFriendListUseCase {
    func getFriendListData() -> Observable<[FriendInfo]>
}

final class DefaultFetchFriendListUseCase: FetchFriendListUseCase {

    private let disposeBag = DisposeBag()
    private let userUUIDRepository: UserUUIDRepository!
    private let userProfileRepository: UserProfileRepository!
    private let fireStoreService: FireStoreService!
    private let userProfile: Single<UserProfile?>
    
    init(userUUIDRepository: UserUUIDRepository, userProfileRepository: UserProfileRepository, fireStoreService: FireStoreService) {
        self.userUUIDRepository = userUUIDRepository
        self.userProfileRepository = userProfileRepository
        
        self.userProfile = fireStoreService.getMyProfile()
    }

    func getFriendListData() -> Observable<[FriendInfo]> {
        self.userProfile
            .asObservable()
            .subscribe(onNext: { profile in
                profile?.chatRooms
            })
            .disposed(by: disposeBag)
    }
    
}
