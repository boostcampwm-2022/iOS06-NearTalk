//
//  DropChatRoomUseCase.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/12/14.
//

import RxSwift

protocol DropChatRoomUseCase {
    /// 방 탈퇴
    func execute(_ userID: String, _ roomID: String) -> Completable
}

final class DefaultDropChatRoomUseCase: DropChatRoomUseCase {
    
    private let chatRoomListRepository: any ChatRoomListRepository
    private let profileRepository: any ProfileRepository
    private let userDefaultsRepository: any UserDefaultsRepository
    
    init(
        chatRoomListRepository: any ChatRoomListRepository,
        profileRepository: any ProfileRepository,
        userDefaultsRepository: any UserDefaultsRepository
    ) {
        self.chatRoomListRepository = chatRoomListRepository
        self.profileRepository = profileRepository
        self.userDefaultsRepository = userDefaultsRepository
    }
    
    /// 방 탈퇴
    func execute(_ userID: String, _ roomID: String) -> Completable {
        self.profileRepository.fetchMyProfile()
            .flatMapCompletable { profile in
                var copy: UserProfile = profile
                copy.chatRooms = profile.chatRooms?.filter { $0 != roomID }
                self.userDefaultsRepository.saveUserProfile(copy)
                return self.profileRepository.updateMyProfile(copy)
                    .asCompletable()
                    .andThen(self.chatRoomListRepository.dropUserFromChatRoom(userID, roomID))
            }
    }
}

enum DropChatRoomUseCaseError: Error {
    case faildToExit
}
