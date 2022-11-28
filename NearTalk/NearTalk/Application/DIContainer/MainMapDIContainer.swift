//
//  MainMapDIContainer.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/23.
//

import Swinject
import UIKit

final class MainMapDIContainer {
    private let container: Container
    
    init(
        container: Container,
        navigationController: UINavigationController,
        actions: MainMapViewModel.Actions
    ) {
        self.container = Container(parent: container)
        self.registerUseCase()
        self.registerViewModel(actions: actions)
    }
    
    private func registerUseCase() {
        self.container.register(FetchAccessibleChatRoomsUseCase.self) { _ in
            let resolvedAccessibleChatRoomsRepository = self.container.resolve(AccessibleChatRoomsRepository.self)!
            let repositories = DefaultFetchAccessibleChatRoomsUseCase.Repositories(accessibleChatRoomsRepository: resolvedAccessibleChatRoomsRepository)
            
            return DefaultFetchAccessibleChatRoomsUseCase(repositories: repositories)
        }
    }
    
    private func registerViewModel(actions: MainMapViewModel.Actions) {
        self.container.register(MainMapViewModel.self) { _ in
            let useCases = MainMapViewModel.UseCases(
                fetchAccessibleChatRoomsUseCase: self.container.resolve(FetchAccessibleChatRoomsUseCase.self)!
            )
            
            return MainMapViewModel(actions: actions, useCases: useCases)
        }
    }
}
