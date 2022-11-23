//
//  MainMapCoordinator.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/14.
//

import UIKit

protocol MainMapCoordinatorDependencies {
    func makeMainMapViewController(actions: MainMapViewModel.Actions) -> MainMapViewController
    func makeBottomSheetViewController() -> BottomSheetViewController
}

final class MainMapCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var parentCoordinator: Coordinator?
    private let dependencies: MainMapCoordinatorDependencies
    
    private weak var mainMapVC: MainMapViewController?
    private weak var bottomSheetVC: BottomSheetViewController?
    
    init(navigationController: UINavigationController? = nil, dependencies: MainMapCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let actions = MainMapViewModel.Actions(
            showCreateChatRoomView: self.showCreateChatRoomView,
            showBottomSheetView: self.showBottomSheetView
        )
        
        self.mainMapVC = dependencies.makeMainMapViewController(actions: actions)
        self.bottomSheetVC = dependencies.makeBottomSheetViewController()
        
        if let mainMapVC = self.mainMapVC {
            self.navigationController?.pushViewController(mainMapVC, animated: true)
        }
    }
    
    // MARK: - Actions
    private func showCreateChatRoomView() {
        // TODO: 채팅방 생성 뷰 보여주는 로직 추가
    }
    
    private func showBottomSheetView() {
        guard let mainMapVC = self.mainMapVC,
              let bottomSheetVC = self.bottomSheetVC
        else {
            return
        }
        
        mainMapVC.present(bottomSheetVC, animated: true)
    }
}
