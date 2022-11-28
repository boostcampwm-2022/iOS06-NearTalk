//
//  MyProfileViewModel.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import Foundation
import RxCocoa
import RxRelay
import RxSwift

protocol MyProfileViewModelAction {
    var showAppSettingView: (() -> Void)? { get }
    var showProfileSettingView: ((UserProfile, NecessaryProfileComponent?) -> Void)? { get }
}

protocol MyProfileInput {
    func moveToAppSettingView()
    func moveToProfileSettingView(necessaryProfileComponent: NecessaryProfileComponent)
    func viewWillAppear()
}

protocol MyProfileOutput {
    var nickName: BehaviorRelay<String?> { get }
    var message: BehaviorRelay<String?> { get }
    var image: BehaviorRelay<String?> { get }
}

protocol MyProfileViewModel: MyProfileInput, MyProfileOutput {}

final class DefaultMyProfileViewModel: MyProfileViewModel {
    func moveToAppSettingView() {
        self.action.showAppSettingView?()
    }
    
    func moveToProfileSettingView(necessaryProfileComponent: NecessaryProfileComponent) {
        self.action.showProfileSettingView?(self.profile, necessaryProfileComponent)
    }
    
    let nickName: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let message: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let image: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    private let profileRepository: any ProfileRepository
    private let mediaRepository: any MediaRepository
    private let action: any MyProfileViewModelAction
    private var profile: UserProfile = UserProfile()
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(profileRepository: any ProfileRepository,
         mediaRepository: any MediaRepository,
         action: any MyProfileViewModelAction) {
        self.profileRepository = profileRepository
        self.mediaRepository = mediaRepository
        self.action = action
    }
    
    func viewWillAppear() {
        self.profileRepository.fetchMyProfile()
            .subscribe(onSuccess: { [weak self] profile in
                self?.nickName.accept(profile.username)
                self?.message.accept(profile.statusMessage)
                self?.downloadImage(path: profile.profileImagePath)
                self?.profile = profile
            }, onFailure: {
                print("fetch profile error: \($0)")
            })
            .disposed(by: self.disposeBag)
    }
    
    private func downloadImage(path: String?) {
        self.image.accept(path)
//        guard let path = path else {
//            self.image.accept(nil)
//            return
//        }
//
//        self.imageRepository.fetch(path: path)
//            .subscribe(onSuccess: { [weak self] imageData in
//                self?.image.accept(imageData)
//            })
//            .disposed(by: self.disposeBag)
    }
}
