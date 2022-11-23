//
//  RemoveFriendUseCase.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/21.
//

import Foundation

import RxSwift

protocol RemoveFriendUseCase {
    func removeFriend(with userID: String) -> Completable
}

final class DefaultRemoveFriendUseCase: RemoveFriendUseCase {
    private let disposebag: DisposeBag = DisposeBag()
    private let userProfileRepository: ProfileRepository
    
    init(profileRepository: ProfileRepository) {
        self.userProfileRepository = profileRepository
    }
    
    func removeFriend(with userID: String) -> Completable {
        print(#function)
        // 1. firebase에서 삭제 -> O
        // 2. Coredata에서 삭제 -> ?
        
        return Completable.create { completable in
            self.userProfileRepository.removeFriend(userID)
                .subscribe { event in
                    switch event {
                    case .completed:
                        completable(.completed)
                    case .error(let error):
                        completable(.error(error))
                    }
                }.disposed(by: self.disposebag)
            return Disposables.create()
        }
    }
}
