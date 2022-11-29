//
//  ChatDIContainer.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

final class ChatDIContainer {
    private let chatRoomID: String
    private let chatRoomName: String
    
    init(chatRoomID: String,
         chatRoomName: String
    ) {
        self.chatRoomID = chatRoomID
        self.chatRoomName = chatRoomName
    }
    
    // MARK: - Dependencies
    
    // MARK: - Persistent Storage
    
    // MARK: - Services
    
    func makeRealTimeDatabaseService() -> RealTimeDatabaseService {
        return DefaultRealTimeDatabaseService()
    }
    
    func makeFCMService() -> FCMService {
        return DefaultFCMService()
    }
    
    // MARK: - UseCases
    
    func makeMessggingUseCase() -> MessagingUseCase {
        return DefalultMessagingUseCase(chatMessageRepository: makeChatMessageRepository())
    }
    
    // MARK: - Repositories
    
    func makeChatMessageRepository() -> ChatMessageRepository {
        return DefaultChatMessageRepository(
            databaseService: makeRealTimeDatabaseService(),
            fcmService: makeFCMService())
    }
    
    // MARK: - View Controller
    
    func makeChatViewController() -> ChatViewController {
        return ChatViewController(viewModel: makeChatViewModel())
    }
    
    func makeChatViewModel() -> ChatViewModel {
        return DefaultChatViewModel(
            chatRoomID: self.chatRoomID,
            chatRoomName: self.chatRoomName,
            messagingUseCase: makeMessggingUseCase())
    }
    // MARK: - Coordinator
    func makeChatCoordinator(navigationController: UINavigationController) -> ChatCoordinator {
        return ChatCoordinator(navigationController: navigationController, dependencies: self)
    }
    // MARK: - DI Container
    
}

extension ChatDIContainer: ChatCoordinatorDependencies {}
