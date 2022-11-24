//
//  FriendListDIContainer.swift
//  NearTalk
//
//  Created by 김영욱 on 2022/11/21.
//

import UIKit

final class FriendListDIContainer {
    
    // MARK: - Dependencies
    struct Dependencies {
        let firestoreService: FirestoreService
        let firebaseAuthService: AuthService
    }
    
    private let dependencies: Dependencies
    
    // MARK: - Persistent Storage
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Services
    
    // MARK: - UseCases
    func makeFetchFriendListUseCase() -> FetchFriendListUseCase {
        return DefaultFetchFriendListUseCase(profileRepository: self.makeRepository())
    }
    
    // MARK: - Repositories
    func makeRepository() -> ProfileRepository {
        return DefaultProfileRepository(firestoreService: dependencies.firestoreService, firebaseAuthService: dependencies.firebaseAuthService)
    }
    
    // MARK: - Friend Lsit
    func makeFriendListViewController(actions: FriendListViewModelActions) -> FriendListViewController {
        return FriendListViewController.create(with: self.makeFriendListViewModel(actions: actions))
    }
    
    func makeFriendListViewModel(actions: FriendListViewModelActions) -> FriendListViewModel {
        return DefaultFriendListViewModel(useCase: self.makeFetchFriendListUseCase(), actions: actions)
    }
    
    // MARK: - Profile Detail
//    func makeProfileDetailViewController() -> ProfileDetailViewController {
//        return ProfileDetailViewController(viewModel: makeProfileDetailViewModel())
//    }
//
//    func makeProfileDetailViewModel() -> ProfileDetailViewModel {
//        return ProfileDetailViewModel(profileDetailUseCase: self.makeProfileDetailUseCaseAble(), profileDetailCoordinator: self.makeProfileDetailCoordinator(makeFriendListCoordinator))
//    }
    
    // MARK: - Coordinator
    func makeFriendListCoordinator(navigationController: UINavigationController) -> FriendListCoordinator {
        return FriendListCoordinator(navigationController: navigationController, dependencies: self)
    }
    
//    func makeProfileDetailDIContainer() -> ProfileDetailDIContainer {
//        let dependencies = ProfileDetailDIContainer.Dependencies()
//        return ProfileDetailDICOntainer(dependencies: dependencies)
//    }
}

extension FriendListDIContainer: FriendListCoordinatorDependencies {
    func makeProfileDetailViewController(userID: String) -> ProfileDetailViewController {
        let diContainer: ProfileDetailDIContainer = ProfileDetailDIContainer()

        let viewController: ProfileDetailViewController = diContainer.createProfileDetailViewController(userID: userID, actions: ProfileDetailViewModelActions())
        return viewController
    }
}
