//
//  ChatRoomListDIContainer.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import UIKit

final class ChatRoomListDIContainer {
    
    // MARK: - Dependencies
    struct Dependencies {
        let apiDataTransferService: StorageService
        let imageDataTransferService: StorageService
    }
    
    private let dependencies: Dependencies
    
    // MARK: - Persistent Storage
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Services
    func makeFirestoreService() -> FirestoreService {
        return DefaultFirestoreService()
    }
    
    func makeDatabaseService() -> RealTimeDatabaseService {
        return DefaultRealTimeDatabaseService()
    }
    
    func makeAuthService() -> AuthService {
        return DefaultFirebaseAuthService()
    }
    
    // MARK: - Repository
    func makeProfileRepository() -> ProfileRepository {
        return DefaultProfileRepository(
            firestoreService: makeFirestoreService(),
            firebaseAuthService: makeAuthService()
        )
    }

    // MARK: - UseCases
    func makeChatRoomListUseCase() -> FetchChatRoomUseCase {
        return DefaultFetchChatRoomUseCase(chatRoomListRepository: self.makeRepository())
    }
    
    // MARK: - Repositories
    func makeRepository() -> ChatRoomListRepository {
        return DefaultChatRoomListRepository(
            dataTransferService: dependencies.apiDataTransferService,
            profileRepository: makeProfileRepository(),
            databaseService: makeDatabaseService(),
            firestoreService: makeFirestoreService()
        )
    }
    
    // ExampleMVVM에서는 보여줄수 있는 Scene의 뷰컨트롤러와 뷰모델이 존재
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
    func makeChatDIContainer() -> ChatDIContainer {
        return ChatDIContainer()
    }
}

extension ChatRoomListDIContainer: ChatRoomListCoordinatorDependencies {}
