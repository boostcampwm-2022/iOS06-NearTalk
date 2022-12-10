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
         authRepository: any AuthRepository,
         chatRoomListRepository: any ChatRoomListRepository) {
        self.profileRepository = profileRepository
        self.userDefaultsRepository = userDefaultsRepository
        self.authRepository = authRepository
        self.chatRoomListRepository = chatRoomListRepository
    }
    
    func dropout() -> Completable {
        return self.deleteUserFromChatRooms()
            .andThen(self.deleteUserFromFriends())
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
    
    func deleteUserFromFriends() -> Completable {
        guard let uuid = self.userDefaultsRepository.fetchUserProfile()?.uuid
        else {
            return Completable.error(DropoutUseCaseError.invalidUserUUID)
        }
        return Completable.zip(
            self.profileRepository.fetchFriendsProfile()
                .asObservable()
                .flatMap { Observable.from($0) }
                .flatMap { self.deleteUserFromFriend(uuid: uuid, friendProfile: $0).asObservable() }
                .asCompletable()
            )
    }
    
    func deleteUserFromFriend(uuid: String, friendProfile: UserProfile) -> Completable {
        var copy: UserProfile = friendProfile
        copy.friends = friendProfile.friends?.filter { $0 != uuid }
        return self.profileRepository.updateFriendProfile(copy)
    }
}

enum DropoutUseCaseError: Error {
    case invalidUserUUID
}
