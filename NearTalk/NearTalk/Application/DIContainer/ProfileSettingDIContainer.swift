//
//  ProfileSettingDIContainer.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/22.
//

import Foundation
import UIKit

final class DefaultProfileSettingDIContainer: ProfileSettingCoordinatorDependency {
    func makeProfileSettingViewController(action: ProfileSettingViewModelAction) -> ProfileSettingViewController {
        let viewModel: any ProfileSettingViewModel = DefaultProfileSettingViewModel(
            updateProfileUseCase: dependency.updateProfileUseCase,
            validateNickNameUseCase: dependency.validateNickNameUseCase,
            validateStatusMessageUseCase: dependency.validateStatusMessageUseCase,
            uploadImageUseCase: dependency.uploadImageUseCase,
            action: action,
            profile: self.dependency.profile)
        return ProfileSettingViewController(
            viewModel: viewModel,
            neccesaryProfileComponent: dependency.necessaryProfileComponent)
    }
    
    struct Dependency {
        let updateProfileUseCase: any UpdateProfileUseCase
        let validateNickNameUseCase: any ValidateTextUseCase
        let validateStatusMessageUseCase: any ValidateTextUseCase
        let uploadImageUseCase: any UploadImageUseCase
        let profile: UserProfile
        let necessaryProfileComponent: NecessaryProfileComponent?
    }
    
    private let dependency: Dependency
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
}
