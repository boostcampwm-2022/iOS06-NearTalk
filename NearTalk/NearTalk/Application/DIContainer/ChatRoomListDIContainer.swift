//
//  ChatRoomListDIContainer.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import UIKit

final class ChatRoomListDIContainer {
    
    // MARK: - Dependencies
    
    // MARK: - Persistent Storage
    
    // MARK: - Services
    
    private let dataTransferService: StorageService = DefaultStorageService()
    
    func makeFirestoreService() -> FirestoreService {
        return DefaultFirestoreService()
    }
    
    func makeDatabaseService() -> RealTimeDatabaseService {
        return DefaultRealTimeDatabaseService()
    }
    
    func makeAuthService() -> AuthService {
        return DefaultFirebaseAuthService()
    }
    
    func makeFCMService() -> FCMService {
        return DefaultFCMService()
    }
    
    // MARK: - Repository
    func makeProfileRepository() -> ProfileRepository {
        return DefaultProfileRepository(
            firestoreService: makeFirestoreService(),
            firebaseAuthService: makeAuthService()
        )
    }
    
    func makeChatMessageRepository() -> ChatMessageRepository {
        return DefaultChatMessageRepository(databaseService: makeDatabaseService(), fcmService: makeFCMService())
    }

    // MARK: - UseCases
    func makeChatRoomListUseCase() -> FetchChatRoomUseCase {
        return DefaultFetchChatRoomUseCase(chatRoomListRepository: self.makeRepository(), chatMessageRepository: self.makeChatMessageRepository())
    }
    
    // MARK: - Repositories
    func makeRepository() -> ChatRoomListRepository {
        return DefaultChatRoomListRepository(
            dataTransferService: dataTransferService,
            profileRepository: makeProfileRepository(),
            databaseService: makeDatabaseService(),
            firestoreService: makeFirestoreService()
        )
    }
    
    // MARK: - ChatRoom List
    func makeChatRoomListViewController(actions: ChatRoomListViewModelActions) -> ChatRoomListViewController {
        return ChatRoomListViewController.create(with: makeChatRoomListViewModel(actions: actions))
    }
    
    func makeChatRoomListViewModel(actions: ChatRoomListViewModelActions) -> ChatRoomListViewModel {
        return DefaultChatRoomListViewModel(useCase: self.makeChatRoomListUseCase(), actions: actions)
    }
    
    // MARK: - Chat Room
    func makeChatRoomViewController() { }
    
    // func makeChatRoomViewModel() -> ChatRoomViewModel {}
    
    // MARK: - Create Chat Room
    func makeCreateChatRoomViewController() { }
    
    // func makeCreateChatRoomViewModel() -> ChatRoomViewModel {}
    
    // MARK: - Coordinator
    func makeChatRoomListCoordinator(navigationController: UINavigationController) -> ChatRoomListCoordinator {
        return ChatRoomListCoordinator(navigationController: navigationController, dependencies: self)
    }
    
    // MARK: - DIContainer
    func makeChatDIContainer(chatRoomID: String, chatRoomName: String, chatRoomMemberUUIDList: [String]) -> ChatDIContainer {
        return ChatDIContainer(chatRoomID: chatRoomID, chatRoomName: chatRoomName, chatRoomMemberUUIDList: chatRoomMemberUUIDList)
    }
    
    func makeCreateGroupChatDIContainer() -> CreateGroupChatDiContainer {
        return CreateGroupChatDiContainer()
    }
}

extension ChatRoomListDIContainer: ChatRoomListCoordinatorDependencies {}
