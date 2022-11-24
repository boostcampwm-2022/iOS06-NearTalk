//
//  ProfileDetailCoordinator.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/17.
//

import UIKit

final class ProfileDetailCoordinator {
    private let dependency: ProfileDetailCoordinatorDependency
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController,
         dependency: ProfileDetailCoordinatorDependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }
    
    func start() {
        print(#function)
        let actions = ProfileDetailViewModelActions()
        
        let viewController: ProfileDetailViewController = self.dependency.makeProfileDetailViewController(actions: actions)
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    func pushChatViewController(username: String) {
        print(#function)
    }
    
    func pushAlertViewController(username: String) {
        print(#function)
    }
}
