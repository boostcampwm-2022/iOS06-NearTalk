//
//  AppSettingDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/24.
//

import Foundation
import UIKit

final class DefaultAppSettingDIContainer: AppSettingCoordinatorDependency {
    let backToLoginView: (() -> Void)?
    
    func makeAppSettingViewController(action: AppSettingAction) -> AppSettingViewController {
        let viewModel: any AppSettingViewModel = DefaultAppSettingViewModel(
            logoutUseCase: self.makeLogoutUseCase(),
            dropoutUseCase: self.makeDropoutUseCase(),
            action: action)
        return AppSettingViewController(viewModel: viewModel)
    }
    
    struct Dependency {
        let authRepository: any AuthRepository
        let profileRepository: any ProfileRepository
        let userDefaultsRepository: any UserDefaultsRepository
        let chatRoomListRepository: any ChatRoomListRepository
        let backToLoginView: (() -> Void)?
    }
    
    private func makeLogoutUseCase() -> any LogoutUseCase {
        return DefaultLogoutUseCase(
            authRepository: self.dependency.authRepository,
            userDefaultsRepository: self.dependency.userDefaultsRepository)
    }
    
    private func makeDropoutUseCase() -> any DropoutUseCase {
        return DefaultDropOutUseCase(
            profileRepository: self.dependency.profileRepository,
            userDefaultsRepository: self.dependency.userDefaultsRepository,
            authRepository: self.dependency.authRepository,
            chatRoomListRepository: self.dependency.chatRoomListRepository)
    }
    
    private let dependency: Dependency
    
    init(dependency: Dependency) {
        self.dependency = dependency
        self.backToLoginView = dependency.backToLoginView
    }
}
