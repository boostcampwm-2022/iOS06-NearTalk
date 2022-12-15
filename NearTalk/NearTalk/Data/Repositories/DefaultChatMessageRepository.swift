//
//  DefaultChatMessageRepository.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/23.
//

import Foundation
import RxSwift

final class DefaultChatMessageRepository: ChatMessageRepository {
    private let coreDataService: CoreDataService
    private let databaseService: RealTimeDatabaseService
    private let profileRepository: any ProfileRepository
    private let fcmService: FCMService
    private let disposeBag: DisposeBag = .init()
    
    init(
        coreDataService: CoreDataService,
        databaseService: RealTimeDatabaseService,
        profileRepository: any ProfileRepository,
        fcmService: FCMService
    ) {
        self.coreDataService = coreDataService
        self.databaseService = databaseService
        self.profileRepository = profileRepository
        self.fcmService = fcmService
    }
    
    func sendMessage(message: ChatMessage, roomID: String, roomName: String, chatMemberIDList: [String]) -> Completable {
            self.databaseService.sendMessage(message)
                .andThen(self.sendPushNotification(message, roomName, chatMemberIDList))
    }
    
    private func sendPushNotification(_ message: ChatMessage, _ roomName: String, _ chatMemberIDList: [String]) -> Completable {
        self.profileRepository.fetchMyProfile()
            .flatMap { (myProfile: UserProfile) in
                guard let myUUID = myProfile.uuid
                else {
                    return Single.error(DefaultChatMessageRepositoryError.fetchProfileInfoError)
                }
                let chatMembersWithoutMyProfile = chatMemberIDList.filter({ $0 != myUUID })
                if chatMembersWithoutMyProfile.count == 0 {
                    return .just([]) // 파이어베이스의 "in" 쿼리가 빈 배열을 인자로 받으면 에러를 던지기 때문에 따로 처리해줘야 한다.
                }
                return self.profileRepository.fetchProfileByUUIDList(chatMembersWithoutMyProfile)
            }
            .flatMapCompletable { (profileList: [UserProfile]) in
                guard profileList.count > 0
                else {
                    return .empty()
                }
                return self.fcmService.sendMessage(message, roomName, profileList.compactMap({ $0.fcmToken }))
            }
    }
    
    func fetchSingleMessage(messageID: String, roomID: String) -> Single<ChatMessage> {
        self.databaseService.fetchSingleMessage(messageID: messageID, roomID: roomID)
    }
    
    func fetchMessage(before message: ChatMessage, count: Int, roomID: String) -> Single<[ChatMessage]> {
        guard let uuid: String = message.uuid,
              let timestamp: Double = message.createdAtTimeStamp
        else {
            return .error(DefaultChatMessageRepositoryError.fetchUUIDError)
        }
        let date: Date = .init(timeIntervalSince1970: timestamp)
        
        let fetchFromNetwork: Single<[ChatMessage]> = self.databaseService.fetchMessages(date: date, pageCount: count, roomID: roomID)
            .do(onSuccess: { (fetchedMessages: [ChatMessage]) in
                fetchedMessages.forEach { msg in
                    guard let uuid = msg.uuid else {
                        return
                    }
                    self.coreDataService.fetchMessage(uuid)
                        .subscribe(onFailure: { error in
                            guard let error = error as? CoreDataServiceError,
                                  error == .failedToFetch else {
                                return
                            }
                            self.coreDataService.saveMessage(msg).subscribe(onCompleted: {
                                print("[저장됨] ", msg.uuid ?? "")
                            }).disposed(by: self.disposeBag)
                        }).disposed(by: self.disposeBag)
                }
            })

        return self.coreDataService.fetchMessage(uuid)
            .catch { error in
                print("🔥 ", #function, error)
                return Single.just(ChatMessage())
            }
            .flatMap { (message: ChatMessage) in
                if message.uuid == nil {
                    return fetchFromNetwork
                } else {
                    return self.coreDataService.fetchMessageList(roomID: roomID, before: date, limit: count)
                }
            }
            .flatMap { (messages: [ChatMessage]) in
                if messages.count < count {
                    return fetchFromNetwork
                } else {
                    print("[캐시된 메세지 불러옴]")
                    return .just(messages)
                }
            }
            .catch { error in
                print("🔥 ", #function, error)
                return fetchFromNetwork
            }
    }
    
    func observeChatRoomMessages(roomID: String) -> Observable<ChatMessage> {
        self.databaseService.observeNewMessage(roomID)
            .do(onNext: { (chatMessage: ChatMessage) in
                guard let uuid = chatMessage.uuid else {
                    return
                }
                self.coreDataService.fetchMessage(uuid)
                    .subscribe(onFailure: { error in
                        guard let error = error as? CoreDataServiceError,
                              error == .failedToFetch else {
                            return
                        }
                        self.coreDataService.saveMessage(chatMessage).subscribe(onCompleted: {
                            print("[저장됨] ", uuid)
                        }).disposed(by: self.disposeBag)
                    }).disposed(by: self.disposeBag)
            })
    }
    
    func updateChatRoom(_ chatRoom: ChatRoom) -> Single<ChatRoom> {
        self.databaseService.updateChatRoom(chatRoom)
    }
}

enum DefaultChatMessageRepositoryError: Error {
    case fetchRoomInfoError
    case fetchProfileInfoError
    case fetchUUIDError
}
