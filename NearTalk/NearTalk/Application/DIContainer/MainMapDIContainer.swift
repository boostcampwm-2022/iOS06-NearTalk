//
//  MainMapDIContainer.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/23.
//

import Foundation
import UIKit

final class MainMapDIContainer {
    
    // MARK: - Dependencies
    struct Dependencies {
        let firestoreService: FirestoreService
        let apiDataTransferService: StorageService
        let imageDataTransferService: StorageService
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Use Cases
    func makeFetchAccessibleChatRoomsUseCase() -> FetchAccessibleChatRoomsUseCase {
        let repositories = DefaultFetchAccessibleChatRoomsUseCase.Repositories
            .init(accessibleChatRoomsRepository: self.makeAccessibleChatRoomsRepository())
        
        return DefaultFetchAccessibleChatRoomsUseCase(repositories: repositories)
    }
    
    // MARK: - Repositories
    func makeAccessibleChatRoomsRepository() -> AccessibleChatRoomsRepository {
        let dependencies = DefaultAccessibleChatRoomsRepository.Dependencies(
            firestoreService: self.dependencies.firestoreService,
            apiDataTransferService: self.dependencies.apiDataTransferService,
            imageDataTransferService: self.dependencies.imageDataTransferService
        )
        
        return DefaultAccessibleChatRoomsRepository(dependencies: dependencies)
    }
    
    // MARK: - ViewModels
    func makeMainMapViewModel(actions: MainMapViewModel.Actions, useCases: MainMapViewModel.UseCases) -> MainMapViewModel {
        return MainMapViewModel(actions: actions, useCases: useCases)
    }
    
    // MARK: - ViewControllers
    func makeMainMapViewController(actions: MainMapViewModel.Actions, useCases: MainMapViewModel.UseCases) -> MainMapViewController {
        let mainMapVM = self.makeMainMapViewModel(actions: actions, useCases: useCases)
        
        return MainMapViewController.create(with: mainMapVM)
    }
    
    func makeBottomSheetViewController() -> BottomSheetViewController {
        return BottomSheetViewController()
    }
    
    // MARK: - Coordinators
    func makeMainMapCoordinator(navigationController: UINavigationController?) -> MainMapCoordinator {
        return MainMapCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }
}

extension MainMapDIContainer: MainMapCoordinatorDependencies {}
