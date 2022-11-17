//
//  MyProfileViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation
import RxRelay
import RxSwift
import RxCocoa

protocol MyProfileViewActions {
    var showAppSettingView: () -> Void { get }
    var showProfileSettingView: () -> Void { get }
}

struct MyProfileInput {
    let refreshObservable: PublishRelay<Void>
}

struct MyProfileOutput {
    let nickNameOutput: Driver<String>
    let messageOutput: Driver<String>
    let imageOutput: Driver<Data?>
}

protocol MyProfileViewModel: ViewModelType where Input == MyProfileInput, Output == MyProfileOutput {
    init(profileLoadUseCase: any MyProfileLoadUseCase)
}

final class DefaultMyProfileViewModel: MyProfileViewModel {
    private let profileLoadUseCase: any MyProfileLoadUseCase
//    private let actions: any MyProfileViewActions
    
    init(profileLoadUseCase: any MyProfileLoadUseCase) {
        self.profileLoadUseCase = profileLoadUseCase
//        self.actions = actions
    }
    
    func transform(_ input: MyProfileInput) -> MyProfileOutput {
        let profileObservable: Observable<UserProfile> = input.refreshObservable
            .map { _ in
                return self.profileLoadUseCase.loadProfile()
            }
        return Output(
            nickNameOutput: profileObservable
                .map {
                    $0.nickName
                }
                .asDriver(onErrorJustReturn: ""),
            messageOutput: profileObservable
                .map {
                    $0.message
                }
                .asDriver(onErrorJustReturn: ""),
            imageOutput: profileObservable
                .map {
                    $0.image
                }
                .asDriver(onErrorJustReturn: nil))
    }

}
