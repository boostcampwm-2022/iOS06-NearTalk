//
//  RootTabBarDIContainer.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/18.
//

import Swinject
import UIKit

typealias BackToLoginViewClosure = () -> Void

final class RootTabBarDIContainer {
    private let container: Container
    
    init(container: Container) {
        self.container = Container(parent: container)
        self.registerViewModel()
    }
    
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

    private func registerViewModel() {
        self.container.register(RootTabBarViewModel.self) { _ in
            DefaultRootTabBarViewModel(useCase: self.makeChatRoomListUseCase())
        }
    }

    // MARK: - Create viewController
    func resolveRootTabBarViewController() -> RootTabBarController {
        return RootTabBarController(viewModel: container.resolve(RootTabBarViewModel.self)!)
    }
    
    func resolveBackToLoginView() -> BackToLoginViewClosure? {
        return self.container.resolve(BackToLoginViewClosure.self)
    }
}
