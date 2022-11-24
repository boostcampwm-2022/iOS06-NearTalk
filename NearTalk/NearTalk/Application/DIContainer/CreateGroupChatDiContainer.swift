//
//  CreateGroupChatDiContainer.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/23.
//

import UIKit

final class CreateGroupChatDiContainer {
    
    // MARK: - Dependencies
    
    // MARK: - Persistent Storage
    
    // MARK: - Services
    
    // MARK: - UseCases
    func makeCreateGroupChatUseCase() -> CreateGroupChatUseCaseable {
        return CreateGroupChatUseCase()
    }
    
    // MARK: - Repositories
    
    // MARK: - View Controller
    
    func makeCreateGroupChatViewController(actions: CreateGroupChatViewModelActions) -> CreateGroupChatViewController {
        return CreateGroupChatViewController(viewModel: makeCreateGroupChatViewModel(actions: actions))
    }
    
    func makeCreateGroupChatViewModel(actions: CreateGroupChatViewModelActions) -> CreateGroupChatViewModel {
        return CreateGroupChatViewModel(createGroupChatUseCase: makeCreateGroupChatUseCase(), actions: actions)
    }
    
    // MARK: - Coordinator
    
    func makeCreateGroupChatCoordinator(navigationCotroller: UINavigationController) -> CreateGroupChatCoordinator {
        return CreateGroupChatCoordinator(navigationController: navigationCotroller, dependencies: self)
    }
    
    // MARK: - DI Container
    
}

extension CreateGroupChatDiContainer: CreateGroupChatCoordinatorDependencies {}
