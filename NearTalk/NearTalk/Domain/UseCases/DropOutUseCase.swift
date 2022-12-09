//
//  DropOutUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/21.
//

import RxSwift

protocol DropoutUseCase {
    func reauthenticate(token: String) -> Completable
    func dropout() -> Completable
}

final class DefaultDropOutUseCase: DropoutUseCase {
    private let profileRepository: any ProfileRepository
    private let userDefaultsRepository: any UserDefaultsRepository
    private let authRepository: any AuthRepository
    private let chatRoomListRepository: any ChatRoomListRepository
    
    init(profileRepository: any ProfileRepository,
         userDefaultsRepository: any UserDefaultsRepository,
         authRepository: any AuthRepository, chatRoomListRepository: any ChatRoomListRepository) {
        self.profileRepository = profileRepository
        self.userDefaultsRepository = userDefaultsRepository
        self.authRepository = authRepository
        self.chatRoomListRepository = chatRoomListRepository
    }
    
    func dropout() -> Completable {
        return self.deleteUserFromChatRooms()
            .andThen(self.deleteUserProfile())
            .andThen(self.authRepository.dropout())
    }
    
    func reauthenticate(token: String) -> Completable {
        self.authRepository.reauthenticate(token: token)
    }
}

private extension DefaultDropOutUseCase {
    func deleteUserProfile() -> Completable {
        self.userDefaultsRepository.removeUserProfile()
        return self.profileRepository.deleteMyProfile()
    }
    
    func deleteUserFromChatRooms() -> Completable {
        self.chatRoomListRepository.dropUserFromChatRooms()
    }
    
//    func deleteUserFromFriends(userProfile: UserProfile) -> Completable {
//
//    }
}

enum DropoutUseCaseError: Error {
    case invalidUserUUID
}
