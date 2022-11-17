//
//  MyProfileCoordinator.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/16.
//

import UIKit

protocol MyProfileCoordinatorDependency {
    func makeMyProfileViewController() -> MyProfileViewController
}

final class MyProfileCoordinator: Coordinator {
    var navigationController: UINavigationController?
    
    weak var parentCoordinator: Coordinator?
    
    var childCoordinators: [Coordinator] = []
    
    func start() {
        showMyProfileViewController()
    }
    
    init(navigationController: UINavigationController? = nil, parentCoordinator: Coordinator? = nil, childCoordinators: [Coordinator] = []) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.childCoordinators = childCoordinators
    }
    
    func showMyProfileViewController() {
        let vc: MyProfileViewController = MyProfileViewController(
            coordinator: self,
            viewModel: DefaultMyProfileViewModel(
                profileLoadUseCase: DefaultMyProfileLoadUseCase(
                    profileRepository: DefaultUserProfileRepository(),
                    uuidRepository: DefaultUserUUIDRepository())))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAppSettingViewController() {
        let vc: AppSettingViewController = AppSettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showProfileSettingViewController() {
        let vc: ProfileSettingViewController = ProfileSettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
