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
    let showChatViewController: (String) -> Void
    var showChatListViewController: (() -> Void)?
}

protocol ProfileDetailViewModelInput {
    var startChatButtonDidTapEvent: PublishRelay<Void> { get set }
    var deleteFriendButtonDidTapEvent: PublishRelay<Void> { get set }
}

protocol ProfileDetailViewModelOutput {
    var userName: BehaviorRelay<String> { get }
    var statusMessage: BehaviorRelay<String> { get }
    var profileImageURL: BehaviorRelay<String?> { get }
}

protocol ProfileDetailViewModelable: ProfileDetailViewModelInput, ProfileDetailViewModelOutput {
    
}

final class ProfileDetailViewModel: ProfileDetailViewModelable {
    var userName: BehaviorRelay<String> = BehaviorRelay<String>(value: "..Loading")
    
    var statusMessage: BehaviorRelay<String> = BehaviorRelay<String>(value: "..Loading")
    
    var profileImageURL: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    
    var startChatButtonDidTapEvent = PublishRelay<Void>()
    
    var deleteFriendButtonDidTapEvent = PublishRelay<Void>()
    
    private var userID: String
    private var myID: String?
    private let fetchProfileUseCase: FetchProfileUseCase
    private let uploadChatRoomInfoUseCase: UploadChatRoomInfoUseCase
    private let removeFriendUseCase: RemoveFriendUseCase
    private let updateProfileUseCase: UpdateProfileUseCase
    private let actions: ProfileDetailViewModelActions
    
    private let disposeBag = DisposeBag()
    
    init(userID: String,
         fetchProfileUseCase: FetchProfileUseCase,
         uploadChatRoomInfoUseCase: UploadChatRoomInfoUseCase,
         removeFriendUseCase: RemoveFriendUseCase,
         updateProfileUseCase: UpdateProfileUseCase,
         actions: ProfileDetailViewModelActions) {
        self.userID = userID
        self.fetchProfileUseCase = fetchProfileUseCase
        self.uploadChatRoomInfoUseCase = uploadChatRoomInfoUseCase
        self.removeFriendUseCase = removeFriendUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.actions = actions
        self.bind()
        
        self.fetchProfileUseCase.fetchUserProfile(with: self.userID)
            .subscribe(onSuccess: { info in
                self.userName.accept(info.username ?? "Unkown")
                self.statusMessage.accept(info.statusMessage ?? "Unkown")
                self.profileImageURL.accept(info.profileImagePath)
            }, onFailure: { error in
                print("ERROR: fetchUserInfo - ", error.localizedDescription)
            })
            .disposed(by: self.disposeBag)
        
        self.fetchProfileUseCase.fetchMyProfile()
            .subscribe(onSuccess: { [weak self] profile in
                self?.myID = profile.uuid
            })
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        
        startChatButtonDidTapEvent
            .subscribe(onNext: { [weak self] in
                guard let self,
                      let myID = self.myID
                else { return }
                
                let chatRoomUUID = UUID().uuidString
                
                let chatRoom: ChatRoom = ChatRoom(uuid: chatRoomUUID,
                                                  userList: [self.userID, myID],
                                                  roomImagePath: nil,
                                                  roomType: "dm",
                                                  roomName: "DM Chat",
                                                  roomDescription: nil,
                                                  location: nil,
                                                  latitude: nil,
                                                  longitude: nil,
                                                  accessibleRadius: nil,
                                                  recentMessageID: nil,
                                                  recentMessageText: nil,
                                                  recentMessageDateTimeStamp: Date().timeIntervalSince1970,
                                                  maxNumberOfParticipants: 2,
                                                  messageCount: nil)
                
                self.fetchProfileUseCase.fetchUserProfile(with: self.userID)
                    .subscribe(onSuccess: { userProfile in
                        var newUserProfile = userProfile
                        newUserProfile.chatRooms?.append(chatRoomUUID)
                        self.updateProfileUseCase.updateFriendsProfile(profile: newUserProfile)
                            .subscribe(onCompleted: {
                                print("상대 프로필 업데이트 완료")
                            })
                            .disposed(by: self.disposeBag)
                        
                    })
                    .disposed(by: self.disposeBag)
                
                self.fetchProfileUseCase.fetchMyProfile()
                    .subscribe(onSuccess: { myProfile in
                        var newMyProfile = myProfile
                        newMyProfile.chatRooms?.append(chatRoomUUID)
                        self.fetchProfileUseCase.updateUserProfile(userProfile: newMyProfile)
                            .subscribe(onSuccess: { _ in
                                print("내 프로필 업데이트")
                            })
                            .disposed(by: self.disposeBag)
                            
                    })
                    .disposed(by: self.disposeBag)
                
                self.uploadChatRoomInfoUseCase.createChatRoom(chatRoom)
                    .subscribe(onCompleted: { self.actions.showChatViewController(chatRoomUUID) })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        deleteFriendButtonDidTapEvent
            .subscribe(onNext: { [weak self] in
                guard let self else {
                    return
                }
                print("deleteFriendButtonDidTapEvent")
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
