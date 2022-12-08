//
//  CreateGroupChatDiContainer.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/23.
//

import UIKit

final class CreateGroupChatDiContainer {

    // MARK: - Dependencies

    // MARK: - Persistent Storage

    // MARK: - Services
    
    func makeUserDefaultService() -> UserDefaultService {
        return DefaultUserDefaultsService()
    }
    
    func makeDataTransferService() -> StorageService {
        return DefaultStorageService()
    }
    
    func makeDatabaseService() -> RealTimeDatabaseService {
        return DefaultRealTimeDatabaseService()
    }
    
    func makeFirestoreService() -> FirestoreService {
        return DefaultFirestoreService()
    }
    
    func makeAuthService() -> AuthService {
        return DefaultFirebaseAuthService()
    }
    
    func makeStorageService() -> StorageService {
        return DefaultStorageService()
    }

    // MARK: - UseCases
    
    func makeCreateGroupChatUseCase() -> CreateGroupChatUseCase {
        return DefaultCreateGroupChatUseCase(chatRoomListRepository: makeCreateGroupChatRepository(), profileRepository: makeProfileRepository())
    }
    
    func makeUserDefaultUseCase() -> UserDefaultUseCase {
        return DefaultUserDefaultUseCase(userDefaultsRepository: self.makeUserDefaultsRepository())
    }
    
    func makeUploadImageUseCase() -> UploadImageUseCase {
        return DefaultUploadImageUseCase(mediaRepository: self.makeMediaRepository())
    }

    // MARK: - Repositories
    
    func makeUserDefaultsRepository() -> UserDefaultsRepository {
        return DefaultUserDefaultsRepository(userDefaultsService: self.makeUserDefaultService())
    }
    
    func makeProfileRepository() -> ProfileRepository {
        return DefaultProfileRepository(
            firestoreService: makeFirestoreService(),
            firebaseAuthService: makeAuthService())
    }
    
    func makeCreateGroupChatRepository() -> ChatRoomListRepository {
        return DefaultChatRoomListRepository(
            dataTransferService: makeDataTransferService(),
            profileRepository: makeProfileRepository(),
            databaseService: makeDatabaseService(),
            firestoreService: makeFirestoreService())
    }
    
    func makeMediaRepository() -> MediaRepository {
        return DefaultMediaRepository(storageService: self.makeStorageService())
    }

    // MARK: - View Controller

    func makeCreateGroupChatViewController(actions: CreateGroupChatViewModelActions) -> CreateGroupChatViewController {
        return CreateGroupChatViewController(viewModel: makeCreateGroupChatViewModel(actions: actions))
    }

    func makeCreateGroupChatViewModel(actions: CreateGroupChatViewModelActions) -> CreateGroupChatViewModel {
        return DefaultCreateGroupChatViewModel(
            createGroupChatUseCase: self.makeCreateGroupChatUseCase(),
            userDefaultUseCase: self.makeUserDefaultUseCase(), uploadImageUseCase: self.makeUploadImageUseCase(),
            actions: actions)
    }

    // MARK: - Coordinator

    func makeCreateGroupChatCoordinator(navigationCotroller: UINavigationController) -> CreateGroupChatCoordinator {
        return CreateGroupChatCoordinator(navigationController: navigationCotroller, dependencies: self)
    }

    // MARK: - DI Container
    
    func makeChatDIContainer(chatRoomID: String) -> ChatDIContainer {
        return ChatDIContainer(chatRoomID: chatRoomID)
    }
}

extension CreateGroupChatDiContainer: CreateGroupChatCoordinatorDependencies {}
