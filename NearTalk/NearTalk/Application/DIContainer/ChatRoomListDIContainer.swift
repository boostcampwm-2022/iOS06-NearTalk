//
//  ChatRoomListDIContainer.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/15.
//

import UIKit

// ChatRoomListDIContainer가 필요한 DIContainer
final class XXXDIContainer {
    // MARK: - 필요한 데이터를 가저올 네트워크 통신
    lazy var apiDataStorageService: DefaultStorageService = {
        // api -> Data 변환
        return DefaultStorageService()
    }()
    
    lazy var imageDataStorageService: DefaultStorageService = {
        // api -> Data 변환
        return DefaultStorageService()
    }()
    
    func makeChatRoomListDIContainer() -> ChatRoomListDIContainer {
        let dependencies = ChatRoomListDIContainer.Dependencies(apiDataTransferService: apiDataStorageService, imageDataTransferService: imageDataStorageService)
        return ChatRoomListDIContainer(dependencies: dependencies)
    }
}

final class ChatRoomListDIContainer {
    
    // MARK: - Dependencies
    struct Dependencies {
        let apiDataTransferService: DefaultStorageService
        let imageDataTransferService: DefaultStorageService
    }
    
    private let dependencies: Dependencies
    
    // MARK: - Persistent Storage
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Services

    // MARK: - UseCases
    func makeChatRoomListUseCase() -> ChatRoomListUseCase {
        return DefaultChatRoomListUseCase(chatRoomListRepository: self.makeRepository())
    }
    
    // MARK: - Repositories
    func makeRepository() -> ChatRoomListRepository {
        return DefaultChatRoomListRepository(dataTransferService: dependencies.apiDataTransferService)
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
}

extension ChatRoomListDIContainer: ChatRoomListCoordinatorDependencies {}
