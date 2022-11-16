//
//  ChatRoomListDIContainer.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import UIKit

final class ChatRoomListDIContainer {
    // MARK: - Dependencies
    
    // MARK: - Services

    // MARK: - UseCases
    func makeChatRoomListUseCase() -> ChatRoomListUseCase {
        return DefaultChatRoomListUseCase(chatRoomListRepository: self.makeRepository())
    }
    
    // MARK: - Repositories
    private func makeRepository() -> ChatRoomListRepository {
        return DefaultChatRoomListRepository()
    }
    
    // MARK: - ViewModels
    func makeViewModel(actions: ChatRoomListViewModelActions) -> ChatRoomListViewModel {
        return DefaultChatRoomListViewModel(
            useCase: self.makeChatRoomListUseCase(),
            actions: actions
        )
    }
    
    // MARK: - Create viewController
    func createChatRoomListViewController(actions: ChatRoomListViewModelActions, coordinator: ChatRoomListCoordinator) -> ChatRoomListViewController {
        return ChatRoomListViewController(viewModel: self.makeViewModel(actions: actions), coordinator: coordinator)
    }
    
    // MARK: - Coordinator
    func makeChatRoomListCoordinator(navigationController: UINavigationController?, dependency: ChatRoomListCoordinatorDependency) -> ChatRoomListCoordinator {
        return ChatRoomListCoordinator(navigationController: navigationController, dependency: dependency)
    }
}
