//
//  ProfileDetailCoordinator.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/17.
//

import UIKit

final class ProfileDetailCoordinator: ProfileDetailCoordinatable {
    var navigationController: UINavigationController?
    
    var parentCoordinator: Coordinator?
    
    var childCoordinators: [Coordinator] = []
    
    func start() {
        print(#function)
    }
    
    func pushChatViewController(username: String) {
        print(#function)
    }
    
    func pushAlertViewController(username: String) {
        print(#function)
    }
}
