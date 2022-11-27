//
//  MyProfileCoordinator.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/16.
//

import PhotosUI
import RxCocoa
import RxSwift
import UIKit

protocol MyProfileCoordinatorDependency {
    func makeMyProfileViewController(action: any MyProfileViewModelAction) -> MyProfileViewController
    func makeProfileSettingCoordinatorDependency(
        profile: UserProfile,
        necessaryProfileComponent: NecessaryProfileComponent?) -> any ProfileSettingCoordinatorDependency
}

final class MyProfileCoordinator: Coordinator {
    var navigationController: UINavigationController?
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private let dependency: any MyProfileCoordinatorDependency
    
    init(navigationController: UINavigationController? = nil,
         parentCoordinator: Coordinator? = nil,
         childCoordinators: [Coordinator] = [],
         dependency: any MyProfileCoordinatorDependency) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.childCoordinators = childCoordinators
        self.dependency = dependency
    }
    
    struct Action: MyProfileViewModelAction {
        let showAppSettingView: (() -> Void)?
        let showProfileSettingView: ((UserProfile, NecessaryProfileComponent?) -> Void)?
    }
    
    func start() {
        showMyProfileViewController()
    }
    
    func showMyProfileViewController() {
        let viewController: MyProfileViewController = self.dependency.makeMyProfileViewController(action: Action(
            showAppSettingView: self.showAppSettingViewController,
            showProfileSettingView: self.showProfileSettingViewController))
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showAppSettingViewController() {
//        print(#function)
        let viewController: AppSettingViewController = AppSettingViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showProfileSettingViewController(profile: UserProfile, necessaryProfileComponent: NecessaryProfileComponent?) {
        let coordinator: ProfileSettingCoordinator = ProfileSettingCoordinator(
            navigationController: self.navigationController,
            dependency: self.dependency.makeProfileSettingCoordinatorDependency(
                profile: profile,
                necessaryProfileComponent: necessaryProfileComponent))
        coordinator.start()
        print(#function)
//        let viewController: ProfileSettingViewController = ProfileSettingViewController(coordinator: self)
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
