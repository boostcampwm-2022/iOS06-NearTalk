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
    
    func makeCoreDataService() -> CoreDataService {
        return DefaultCoreDataService()
    }
    
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
    
    func makeChatRoomListRepository() -> ChatRoomListRepository {
        return DefaultChatRoomListRepository(
            dataTransferService: dataTransferService,
            profileRepository: makeProfileRepository(),
            databaseService: makeDatabaseService(),
            firestoreService: makeFirestoreService())
    }
    func makeProfileRepository() -> ProfileRepository {
        return DefaultProfileRepository(
            firestoreService: makeFirestoreService(),
            firebaseAuthService: makeAuthService()
        )
    }
    
    func makeChatMessageRepository() -> ChatMessageRepository {
        return DefaultChatMessageRepository(
            coreDataService: makeCoreDataService(),
            databaseService: makeDatabaseService(),
            profileRepository: makeProfileRepository(),
            fcmService: makeFCMService()
        )
    }
    
    func makeUserDefaultsRepository() -> UserDefaultsRepository {
        return DefaultUserDefaultsRepository(userDefaultsService: DefaultUserDefaultsService())
    }

    // MARK: - UseCases
    func makeChatRoomListUseCase() -> FetchChatRoomUseCase {
        return DefaultFetchChatRoomUseCase(chatRoomListRepository: makeChatRoomListRepository(),
                                           profileRepository: makeProfileRepository(),
                                            userDefaultsRepository: makeUserDefaultsRepository())
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
    
    // MARK: - Coordinator
    func makeChatRoomListCoordinator(navigationController: UINavigationController) -> ChatRoomListCoordinator {
        return ChatRoomListCoordinator(navigationController: navigationController, dependencies: self)
    }
    
    // MARK: - DIContainer
    func makeChatDIContainer(chatRoomID: String) -> ChatDIContainer {
        return ChatDIContainer(chatRoomID: chatRoomID)
    }
    
    func makeCreateGroupChatDIContainer() -> CreateGroupChatDIContainer {
        return CreateGroupChatDIContainer()
    }
}

extension ChatRoomListDIContainer: ChatRoomListCoordinatorDependencies {}
