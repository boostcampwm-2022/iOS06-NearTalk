//
//  FetchProfileUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/21.
//

import Foundation

import RxSwift

struct UserProfileDetail {
    let id: String?
    let username: String?
    let imagePath: String?
    let statusMessage: String?
}

protocol FetchProfileUseCase {
    func fetchUserInfo(with userID: String) -> Single<UserProfileDetail>
}

final class DefaultFetchProfileUseCase: FetchProfileUseCase {
    private let disposebag: DisposeBag = DisposeBag()
    private let userProfileRepository: ProfileRepository
    
    init(profileRepository: ProfileRepository) {
        self.userProfileRepository = profileRepository
    }
    
    func fetchUserInfo(with userID: String) -> Single<UserProfileDetail> {
        print(#function)
        return Single<UserProfileDetail>.create { single in
            
            self.userProfileRepository.fetchProfileByUUID(userID)
                .subscribe { event in
                    switch event {
                    case .success(let userProfile):
                        let userProfileDetail = UserProfileDetail(
                            id: userProfile.uuid,
                            username: userProfile.username,
                            imagePath: userProfile.profileImagePath,
                            statusMessage: userProfile.statusMessage
                        )
                        single(.success(userProfileDetail))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }.disposed(by: self.disposebag)
            
            return Disposables.create()
        }
    }
}
