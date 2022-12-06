//
//  MainMapCoordinator.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/14.
//

import UIKit

protocol MainMapCoordinatorDependencies {
    func makeMainMapViewController(actions: MainMapViewModel.Actions, navigationController: UINavigationController) -> MainMapViewController
}

final class MainMapCoordinator: Coordinator {
    var navigationController: UINavigationController?
    private let dependencies: MainMapCoordinatorDependencies
    
    private weak var mainMapVC: MainMapViewController?
    private weak var bottomSheetVC: BottomSheetViewController?
    
    init(navigationController: UINavigationController? = nil, dependencies: MainMapCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        guard let navigationController = navigationController
        else { return }
        
        let actions = MainMapViewModel.Actions(showCreateChatRoomView: self.showCreateChatRoomView)
        let mainMapVC = dependencies.makeMainMapViewController(actions: actions, navigationController: navigationController)
        self.mainMapVC = mainMapVC
        self.navigationController?.pushViewController(mainMapVC, animated: true)
    }
    
    // MARK: - Actions
    func showCreateChatRoomView() {
        guard let navigationController = navigationController
        else { return }

        let diContainer: CreateGroupChatDiContainer = .init()
        let coordinator = diContainer.makeCreateGroupChatCoordinator(navigationCotroller: navigationController)
        coordinator.start()
    }
}
