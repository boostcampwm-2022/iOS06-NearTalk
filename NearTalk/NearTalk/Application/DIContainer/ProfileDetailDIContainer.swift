//
//  ProfileDetailDIContainer.swift
//  NearTalk
//
//  Created by dong eun shin on 2022/11/22.
//

import UIKit

final class ProfileDetailDIContainer {
    // MARK: - Dependencies
    
    private let userID: String
    
    init(userID: String) {
        self.userID = userID
    }
    
    // MARK: - Services
    func makeFirestoreService() -> FirestoreService {
        return DefaultFirestoreService()
    }
    
    func makefirebaseAuthService() -> AuthService {
        return DefaultFirebaseAuthService()
    }
    
    func makeUserDefaultService() -> UserDefaultService {
        return DefaultUserDefaultsService()
    }
    
    func makeDataBaseService() -> RealTimeDatabaseService {
        return DefaultRealTimeDatabaseService()
    }
    
    func makeStorageService() -> StorageService {
        return DefaultStorageService()
    }
    
    // MARK: - UseCases
    func makeFetchProfileUseCase() -> FetchProfileUseCase {
        return DefaultFetchProfileUseCase(profileRepository: self.makeProfileDetailRepository())
    }
    
    func makeUploadChatRoomInfoUseCase() -> UploadChatRoomInfoUseCase {
        let mediaRepository = DefaultMediaRepository(storageService: DefaultStorageService())
        let chatRoomRepository = DefaultChatRoomListRepository(dataTransferService: DefaultStorageService(),
                                                               profileRepository: DefaultProfileRepository(firestoreService: DefaultFirestoreService(), firebaseAuthService: DefaultFirebaseAuthService()),
                                                               databaseService: DefaultRealTimeDatabaseService(),
                                                               firestoreService: DefaultFirestoreService())
        
        return DefaultUploadChatRoomInfoUseCase(mediaRepository: mediaRepository, chatRoomRepository: chatRoomRepository)
    }
    
    func makeRemoveFriendUseCase() -> RemoveFriendUseCase {
        return DefaultRemoveFriendUseCase(profileRepository: self.makeProfileDetailRepository())
    }
    
    func makeUpdateProfileUseCase() -> UpdateProfileUseCase {
        return DefaultUpdateProfileUseCase(repository: makeProfileDetailRepository(), userDefaultsRepository: makeUserDefaultsRepository())
    }
    
    func makeFetchChatRoomUseCase() -> FetchChatRoomUseCase {
        return DefaultFetchChatRoomUseCase(chatRoomListRepository: makeChatRoomListRepository(),
                                           profileRepository: makeProfileDetailRepository(),
                                           userDefaultsRepository: makeUserDefaultsRepository())
    }
    
    // MARK: - Repositories
    func makeProfileDetailRepository() -> ProfileRepository {
        return DefaultProfileRepository(
            firestoreService: self.makeFirestoreService(),
            firebaseAuthService: self.makefirebaseAuthService())
    }
    
    func makeUserDefaultsRepository() -> UserDefaultsRepository {
        return DefaultUserDefaultsRepository(userDefaultsService: makeUserDefaultService())
    }
    
    func makeChatRoomListRepository() -> ChatRoomListRepository {
        return DefaultChatRoomListRepository(dataTransferService: makeStorageService(),
                                             profileRepository: makeProfileDetailRepository(),
                                             databaseService: makeDataBaseService(),
                                             firestoreService: makeFirestoreService())
    }
    
    // MARK: - ViewModels
    func makeProfileDetailViewModel(
        actions: ProfileDetailViewModelActions
    ) -> any ProfileDetailViewModelable {
        return ProfileDetailViewModel(
            userID: self.userID,
            fetchChatRoomUseCase: self.makeFetchChatRoomUseCase(),
            fetchProfileUseCase: self.makeFetchProfileUseCase(),
            uploadChatRoomInfoUseCase: self.makeUploadChatRoomInfoUseCase(),
            removeFriendUseCase: self.makeRemoveFriendUseCase(),
            updateProfileUseCase: self.makeUpdateProfileUseCase(),
            actions: actions)
    }
    
    // MARK: - Create viewController
    func makeProfileDetailViewController(
        actions: ProfileDetailViewModelActions
    ) -> ProfileDetailViewController {
        return ProfileDetailViewController.create(with: self.makeProfileDetailViewModel(
            actions: actions
        ))
    }
    
    // MARK: - Coordinator
    func makeProfileDetailCoordinator(navigationController: UINavigationController) -> ProfileDetailCoordinator {
        return ProfileDetailCoordinator(navigationController: navigationController, dependency: self)
    }
    
    // MARK: - DI Container
    func makeChatDIContainer(chatRoomID: String) -> ChatDIContainer {
        return ChatDIContainer(chatRoomID: chatRoomID)
    }
}

extension ProfileDetailDIContainer: ProfileDetailCoordinatorDependency {}
