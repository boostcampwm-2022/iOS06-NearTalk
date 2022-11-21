//
//  MainMapCoordinator.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/14.
//

import UIKit

protocol MainMapCoordinatorDependencies {
    func makeMainMapViewController(actions: MainMapViewModelActions) -> MainMapViewController
    func makeMainMapViewController(userLocation: NCLocation) -> UIViewController
    func makeMainMapBottomSheetViewController() -> BottomSheetViewController
}

final class MainMapCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: MainMapCoordinatorDependencies
    
    private weak var mainMapVC: MainMapViewController?
    private weak var mainMapBottomSheetVC: BottomSheetViewController?
    
    init(navigationController: UINavigationController, dependencies: MainMapCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let actions = MainMapViewModelActions(
            showMainMapView: self.showMainMapView,
            showBottomSheet: self.showBottomSheet,
            showCreateChatRoomView: self.showCreateChatRoomView
        )
        
        let mainMapVC = dependencies.makeMainMapViewController(actions: actions)
        self.navigationController?.pushViewController(mainMapVC, animated: true)
        self.mainMapVC = mainMapVC
    }
    
    private func showMainMapView(userLocation: NCLocation) {
        let mainMapVC = dependencies.makeMainMapViewController(userLocation: userLocation)
        
        self.navigationController?.pushViewController(mainMapVC, animated: false)
    }
    
    private func showBottomSheet(chatRooms: [ChatRoom]) {
        
    }
    
    private func showCreateChatRoomView(userLocation: NCLocation) {
        
    }
}
