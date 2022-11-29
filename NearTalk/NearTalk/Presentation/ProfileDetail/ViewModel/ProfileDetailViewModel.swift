//
//  ProfileDetailViewModel.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/16.
//

import Foundation

import RxCocoa
import RxSwift

struct ProfileDetailViewModelActions {
    var showChatViewController: (() -> Void)?
    var showChatListViewController: (() -> Void)?
}

protocol ProfileDetailViewModelInput {
    var viewWillAppearEvent: PublishRelay<Void> { get set }
    var startChatButtonDidTapEvent: PublishRelay<Void> { get set }
    var deleteFriendButtonDidTapEvent: PublishRelay<Void> { get set }
}

protocol ProfileDetailViewModelOutput {
    var userName: BehaviorRelay<String> { get }
    var statusMessage: BehaviorRelay<String> { get }
    var profileImageURL: BehaviorRelay<String> { get }
}

protocol ProfileDetailViewModelable: ProfileDetailViewModelInput, ProfileDetailViewModelOutput {
    
}

final class ProfileDetailViewModel: ProfileDetailViewModelable {
    var userName: BehaviorRelay<String> = BehaviorRelay<String>(value: "..Loading")
    
    var statusMessage: BehaviorRelay<String> = BehaviorRelay<String>(value: "..Loading")
    
    var profileImageURL: BehaviorRelay<String> = BehaviorRelay<String>(value: "..Loading")
    
    var viewWillAppearEvent = PublishRelay<Void>()
    
    var startChatButtonDidTapEvent = PublishRelay<Void>()
    
    var deleteFriendButtonDidTapEvent = PublishRelay<Void>()
    
    private let userID: String
    private let fetchProfileUseCase: FetchProfileUseCase
    private let uploadChatRoomInfoUseCase: UploadChatRoomInfoUseCase
    private let removeFriendUseCase: RemoveFriendUseCase
    private let actions: ProfileDetailViewModelActions
    
    private let disposeBag = DisposeBag()
    
    init(userID: String,
         fetchProfileUseCase: FetchProfileUseCase,
         uploadChatRoomInfoUseCase: UploadChatRoomInfoUseCase,
         removeFriendUseCase: RemoveFriendUseCase,
         actions: ProfileDetailViewModelActions) {
        self.userID = userID
        self.fetchProfileUseCase = fetchProfileUseCase
        self.uploadChatRoomInfoUseCase = uploadChatRoomInfoUseCase
        self.removeFriendUseCase = removeFriendUseCase
        self.actions = actions
        self.bind()
    }
    
    private func bind() {
        viewWillAppearEvent
            .subscribe(onNext: { [weak self] in
                guard let self else {
                    return
                }
                self.fetchProfileUseCase.fetchUserInfo(with: self.userID)
                    .subscribe(onSuccess: { info in
                        self.userName.accept(info.username ?? "Unkown")
                        self.statusMessage.accept(info.statusMessage ?? "Unkown")
                        self.profileImageURL.accept(info.profileImagePath ?? "")
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        startChatButtonDidTapEvent
            .subscribe(onNext: { [weak self] in
                // TODO: - DM 구현 필요
//                let chatRoom = ChatRoom(
//                    uuid: <#T##String?#>,
//                    userList: <#T##[String]?#>,
//                    roomImagePath: <#T##String?#>,
//                    roomType: "DM",
//                    roomName: <#T##String?#>,
//                    roomDescription: <#T##String?#>,
//                    location: <#T##NCLocation?#>,
//                    accessibleRadius: <#T##Double?#>,
//                    recentMessageID: <#T##String?#>,
//                    maxNumberOfParticipants: <#T##Int?#>,
//                    messageCount: <#T##Int?#>
//                )
//                self.uploadChatRoomInfoUseCase.createChatRoom(chatRoom)
                self?.actions.showChatViewController?()
            })
            .disposed(by: disposeBag)
        
        deleteFriendButtonDidTapEvent
            .subscribe(onNext: { [weak self] in
                guard let self else {
                    return
                }
                self.removeFriendUseCase.removeFriend(with: self.userID)
                    .subscribe { event in
                        switch event {
                        case .completed:
                            self.actions.showChatListViewController?()
                        case .error(let error):
                            print("ERROR: ", error.localizedDescription)
                        }
                    }
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}
