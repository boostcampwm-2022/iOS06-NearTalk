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
    
    // MARK: - Properties
    var navigationController: UINavigationController?
    private let dependencies: MainMapCoordinatorDependencies
    
    init(navigationController: UINavigationController? = nil, dependencies: MainMapCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Methods
    func start() {
        guard let navigationController = navigationController
        else { return }
        
        let actions = MainMapViewModel.Actions(showCreateChatRoomView: self.showCreateChatRoomView)
        let mainMapVC = dependencies.makeMainMapViewController(actions: actions, navigationController: navigationController)
        self.navigationController?.pushViewController(mainMapVC, animated: true)
    }
    
    // MARK: - View Actions
    func showCreateChatRoomView() {
        guard let navigationController = navigationController
        else { return }

        let diContainer: CreateGroupChatDiContainer = .init()
        let coordinator: CreateGroupChatCoordinator = diContainer.makeCreateGroupChatCoordinator(navigationCotroller: navigationController)
        coordinator.start()
    }
    
    func showBottomSheet(mainMapVC: MainMapViewController, chatRooms: [ChatRoom]) {
        let diContainer: MainMapDIContainer = .init()
        let coordinator: MainMapCoordinator = diContainer.makeMainMapCoordinator(navigationController: navigationController)
        let bottomSheet: BottomSheetViewController = BottomSheetViewController.create(coordinator: coordinator)
        bottomSheet.loadData(with: chatRooms)
    
        mainMapVC.present(bottomSheet, animated: true)
    }
    
    func closeBottomSheet(bottomSheetVC: BottomSheetViewController) {
        bottomSheetVC.dismiss(animated: true)
    }
    
    func showChatRoomView(chatRoomID: String) {
        guard let navigationController = navigationController
        else { return }
        
        let diContainer: ChatDIContainer = ChatRoomListDIContainer().makeChatDIContainer(chatRoomID: chatRoomID)
        let coordinator = diContainer.makeChatCoordinator(navigationController: navigationController)
        coordinator.start()
    }
}
