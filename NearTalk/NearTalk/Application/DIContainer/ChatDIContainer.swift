//
//  ChatDIContainer.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

final class ChatDIContainer {
    private var chatRoomID: String
    private var chatRoomName: String
    private let chatRoomMemberUUIDList: [String]
    
    init(chatRoomID: String,
         chatRoomName: String,
         chatRoomMemberUUIDList: [String]
    ) {
        self.chatRoomID = chatRoomID
        self.chatRoomName = chatRoomName
        self.chatRoomMemberUUIDList = chatRoomMemberUUIDList
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
            profileRepository: DefaultProfileRepository(firestoreService: DefaultFirestoreService(), firebaseAuthService: DefaultFirebaseAuthService()),
            fcmService: makeFCMService()
        )
    }
    
    // MARK: - View Controller
    
    func makeChatViewController() -> ChatViewController {
        return ChatViewController(viewModel: makeChatViewModel())
    }
    
    func makeChatViewModel() -> ChatViewModel {
        return DefaultChatViewModel(
            chatRoomID: self.chatRoomID,
            chatRoomName: self.chatRoomName,
            chatRoomMemberUUIDList: self.chatRoomMemberUUIDList,
            messagingUseCase: makeMessggingUseCase())
    }
    // MARK: - Coordinator
    func makeChatCoordinator(navigationController: UINavigationController) -> ChatCoordinator {
        return ChatCoordinator(navigationController: navigationController, dependencies: self)
    }
    // MARK: - DI Container
    
}

extension ChatDIContainer: ChatCoordinatorDependencies {}
