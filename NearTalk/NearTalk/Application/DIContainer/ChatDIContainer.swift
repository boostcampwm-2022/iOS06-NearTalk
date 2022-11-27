//
//  ChatDIContainer.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

final class ChatDIContainer {
    
    // MARK: - Dependencies
    
    // MARK: - Persistent Storage
    
    // MARK: - Services
    
    // MARK: - UseCases
    
    func makeMessggingUseCase() -> MessagingUseCase {
        return DefalultMessagingUseCase()
    }
    
    // MARK: - Repositories
    
    // MARK: - View Controller
    
    func makeChatViewController() -> ChatViewController {
        return ChatViewController(viewModel: makeChatViewModel())
    }
    
    func makeChatViewModel() -> ChatViewModel {
        return DefaultChatViewModel(messagingUseCase: makeMessggingUseCase())
    }
    // MARK: - Coordinator
    func makeChatCoordinator(navigationController: UINavigationController) -> ChatCoordinator {
        return ChatCoordinator(navigationController: navigationController, dependencies: self)
    }
    // MARK: - DI Container
    
}

extension ChatDIContainer: ChatCoordinatorDependencies {}
