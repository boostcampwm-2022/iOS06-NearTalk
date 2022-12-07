//
//  MainMapDIContainer.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/23.
//

import Foundation
import UIKit

final class MainMapDIContainer {
    
    // MARK: - Services
    private let firestoreService: FirestoreService = DefaultFirestoreService()
    private let apiDataTransferService: StorageService = DefaultStorageService()
    private let imageDataTransferService: StorageService = DefaultStorageService()
    
    // MARK: - Use Cases
    func makeFetchAccessibleChatRoomsUseCase() -> FetchAccessibleChatRoomsUseCase {
        let repositories = DefaultFetchAccessibleChatRoomsUseCase.Repositories
            .init(accessibleChatRoomsRepository: self.makeAccessibleChatRoomsRepository())
        
        return DefaultFetchAccessibleChatRoomsUseCase(repositories: repositories)
    }
    
    // MARK: - Repositories
    func makeAccessibleChatRoomsRepository() -> AccessibleChatRoomsRepository {
        let dependencies = DefaultAccessibleChatRoomsRepository.Dependencies(
            firestoreService: self.firestoreService,
            apiDataTransferService: self.apiDataTransferService,
            imageDataTransferService: self.imageDataTransferService
        )
        
        return DefaultAccessibleChatRoomsRepository(dependencies: dependencies)
    }
    
    // MARK: - ViewModels
    func makeMainMapViewModel(actions: MainMapViewModel.Actions) -> MainMapViewModel {
        let useCases = MainMapViewModel.UseCases(
            fetchAccessibleChatRoomsUseCase: self.makeFetchAccessibleChatRoomsUseCase()
        )
        
        return MainMapViewModel(actions: actions, useCases: useCases)
    }
    
    // MARK: - ViewControllers
    func makeMainMapViewController(actions: MainMapViewModel.Actions, navigationController: UINavigationController) -> MainMapViewController {
        let mainMapVM = self.makeMainMapViewModel(actions: actions)
        
        return MainMapViewController.create(with: mainMapVM,
                                            coordinator: self.makeMainMapCoordinator(navigationController: navigationController))
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
