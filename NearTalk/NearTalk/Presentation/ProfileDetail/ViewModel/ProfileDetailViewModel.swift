//
//  ProfileDetailViewModel.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/16.
//

import Foundation

import RxCocoa
import RxSwift

protocol ProfileDetailCoordinatable: Coordinator {
    func pushChatViewController(username: String)
    func pushAlertViewController(username: String)
}

protocol ProfileDetailUseCaseAble {
    var userName: String? { get }
    var statusMessage: String? { get }
    var profileImageURL: String? { get }
    func fetchUserInfo()
    func deleteUserInFriendList()
}

protocol ViewModelable {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output
}

final class ProfileDetailViewModel: ViewModelable {
    private let profileDetailUseCase: ProfileDetailUseCaseAble
    private let profileDetailCoordinator: ProfileDetailCoordinatable
    
    init(profileDetailUseCase: ProfileDetailUseCaseAble, profileDetailCoordinator: ProfileDetailCoordinator) {
        self.profileDetailUseCase = profileDetailUseCase
        self.profileDetailCoordinator = profileDetailCoordinator
    }
    
    struct Input {
        let viewWillAppearEvent: Observable<Void>
        let startChatButtonDidTapEvent: Observable<Void>
        let deleteFriendButtonDidTapEvent: Observable<Void>
    }
    
    struct Output {
        var username: String
        var statusMessage: String
        var profileImageURL = PublishRelay<String>()
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output(
            username: self.profileDetailUseCase.userName ?? "Unkown username",
            statusMessage: self.profileDetailUseCase.statusMessage ?? "Unkown statusMessage"
        )
        
        input.viewWillAppearEvent
            .subscribe(onNext: { [weak self] in
                self?.profileDetailUseCase.fetchUserInfo()
            })
            .disposed(by: disposeBag)
        
        input.startChatButtonDidTapEvent
            .subscribe(onNext: { [weak self] in
                self?.profileDetailCoordinator.pushChatViewController(username: "username")
                
            })
            .disposed(by: disposeBag)
        
        input.deleteFriendButtonDidTapEvent
            .subscribe(onNext: { [weak self] in
                self?.profileDetailCoordinator.pushAlertViewController(username: "username")
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
