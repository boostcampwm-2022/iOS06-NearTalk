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
    func moveToProfileSettingView()
    func viewWillAppear()
    func selectRow(menu: MyProfileItem?)
}

protocol MyProfileOutput {
    var nickName: Driver<String?> { get }
    var message: Driver<String?> { get }
    var image: Driver<Data?> { get }
}

protocol MyProfileViewModel: MyProfileInput, MyProfileOutput {}

enum MyProfileSection: Hashable, Sendable {
    case main
}

enum MyProfileItem: String, Hashable, Sendable, CaseIterable {
    case profileSetting = "프로필 수정"
    case appSetting = "앱 설정"
}

final class DefaultMyProfileViewModel: MyProfileViewModel {
    var nickName: Driver<String?> {
        self.nickNameRelay.asDriver()
    }
    
    var message: Driver<String?> {
        self.messageRelay.asDriver()
    }
    
    var image: Driver<Data?> {
        self.imageRelay.asDriver()
    }
    
    func moveToAppSettingView() {
        self.action.showAppSettingView?()
    }
    
    func moveToProfileSettingView() {
        self.action.showProfileSettingView?(self.profile,
            .init(nickName: self.nickNameRelay.value,
                  message: self.messageRelay.value,
                  image: self.imageRelay.value))
    }
    
    private let nickNameRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    private let messageRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    private let imageRelay: BehaviorRelay<Data?> = BehaviorRelay(value: nil)
    
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
                self?.nickNameRelay.accept(profile.username)
                self?.messageRelay.accept(profile.statusMessage)
                self?.downloadImage(path: profile.profileImagePath)
                self?.profile = profile
            }, onFailure: {
                print("fetch profile error: \($0)")
            })
            .disposed(by: self.disposeBag)
    }
    
    private func downloadImage(path: String?) {
        guard let path = path else { return }
        self.mediaRepository.fetchImage(path: path)
            .subscribe { [weak self] image in
                self?.imageRelay.accept(image)
            } onFailure: { [weak self] _ in
                self?.imageRelay.accept(nil)
            }
            .disposed(by: self.disposeBag)
    }
    
    func selectRow(menu: MyProfileItem?) {
        guard let menu = menu else {
            return
        }
        switch menu {
        case .profileSetting:
            self.moveToProfileSettingView()
        case .appSetting:
            self.moveToAppSettingView()
        }
    }
}
