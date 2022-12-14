//
//  ChatDIContainer.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/23.
//

import UIKit

final class ChatDIContainer {
    private var chatRoomID: String
    
    init(chatRoomID: String) {
        self.chatRoomID = chatRoomID
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
    
    func makeFirestoreService() -> FirestoreService {
        return DefaultFirestoreService()
    }
    
    func makeAuthService() -> AuthService {
        return DefaultFirebaseAuthService()
    }
    
    func makeUserDefaultService() -> UserDefaultService {
        return DefaultUserDefaultsService()
    }
    
    func makeCoreDataService() -> CoreDataService {
        return DefaultCoreDataService()
    }
    
    // MARK: - UseCases
    
    func makeMessggingUseCase() -> MessagingUseCase {
        return DefalultMessagingUseCase(chatMessageRepository: self.makeChatMessageRepository())
    }
    
    func makeFetchChatRoomInfoUseCase() -> FetchChatRoomInfoUseCase {
        return DefaultFetchChatRoomInfoUseCase(chatRoomListRepository: self.makeChatRoomListRepository())
    }
    
    func makeUserDefaultUseCase() -> UserDefaultUseCase {
        return DefaultUserDefaultUseCase(userDefaultsRepository: self.makeUserDefaultsRepository())
    }
    
    func makeFetchProfileUseCase() -> FetchProfileUseCase {
        return DefaultFetchProfileUseCase(profileRepository: self.makeProfileRepository())
    }
    
    func makeEnterChatRoomUseCase() -> EnterChatRoomUseCase {
        return DefaultEnterChatRoomUseCase(
            chatRoomListRepository: self.makeChatRoomListRepository(),
            profileRepository: self.makeProfileRepository()
        )
    }
    
    func makeDropChatRoomUseCase() -> any DropChatRoomUseCase {
        return DefaultDropChatRoomUseCase(chatRoomListRepository: self.makeChatRoomListRepository(), profileRepository: self.makeProfileRepository(), userDefaultsRepository: self.makeUserDefaultsRepository())
    }
    
    // MARK: - Repositories
    
    func makeUserDefaultsRepository() -> UserDefaultsRepository {
        return DefaultUserDefaultsRepository(userDefaultsService: self.makeUserDefaultService())
    }
    
    func makeChatMessageRepository() -> ChatMessageRepository {
        return DefaultChatMessageRepository(
            coreDataService: makeCoreDataService(),
            databaseService: makeRealTimeDatabaseService(),
            profileRepository: DefaultProfileRepository(
                firestoreService: DefaultFirestoreService(),
                firebaseAuthService: DefaultFirebaseAuthService()),
            fcmService: makeFCMService()
        )
    }
    
    func makeChatRoomListRepository() -> ChatRoomListRepository {
        return DefaultChatRoomListRepository(
            dataTransferService: DefaultStorageService(),
            profileRepository: self.makeProfileRepository(),
            databaseService: DefaultRealTimeDatabaseService(),
            firestoreService: DefaultFirestoreService()
        )
    }
    
    func makeProfileRepository() -> ProfileRepository {
        return DefaultProfileRepository(
            firestoreService: makeFirestoreService(),
            firebaseAuthService: makeAuthService()
        )
    }
    
    // MARK: - View Controller
    
    func makeChatViewController() -> ChatViewController {
        return ChatViewController(viewModel: makeChatViewModel())
    }
    
    func makeChatViewModel() -> ChatViewModel {
        return DefaultChatViewModel(
            chatRoomID: self.chatRoomID,
            fetchChatRoomInfoUseCase: self.makeFetchChatRoomInfoUseCase(),
            userDefaultUseCase: self.makeUserDefaultUseCase(),
            fetchProfileUseCase: self.makeFetchProfileUseCase(),
            messagingUseCase: self.makeMessggingUseCase(),
            enterChatRoomUseCase: self.makeEnterChatRoomUseCase(),
            dropChatRoomUseCase: self.makeDropChatRoomUseCase())
    }
    // MARK: - Coordinator
    func makeChatCoordinator(navigationController: UINavigationController) -> ChatCoordinator {
        return ChatCoordinator(navigationController: navigationController, dependencies: self)
    }
    // MARK: - DI Container
    
}

extension ChatDIContainer: ChatCoordinatorDependencies {}
