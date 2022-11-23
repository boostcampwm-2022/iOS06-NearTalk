//
//  RealTimeDatabaseService.swift
//  NearTalk
//
//  Created by 고병학 on 2022/11/12.
//

import FirebaseDatabase
import Foundation
import RxSwift

protocol RealTimeDatabaseService {
    // MARK: 채팅 메시지
    func sendMessage(_ message: ChatMessage) -> Completable
    func fetchMessages(page: Int, skip: Int, pageCount: Int, roomID: String) -> Single<[ChatMessage]>
    func observeNewMessage(_ chatRoomID: String) -> Observable<ChatMessage>
    
    // MARK: 채팅방 정보
    func createChatRoom(_ chatRoom: ChatRoom) -> Single<ChatRoom>
    func fetchChatRoomInfo(_ chatRoomID: String) -> Single<ChatRoom>
    func observeChatRoomInfo(_ chatRoomID: String) -> Observable<ChatRoom>
    
    // MARK: 유저-채팅방 티켓 정보
    func createUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Completable
    func updateUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Completable
    func fetchUserChatRoomTicketList(_ userID: String) -> Single<[UserChatRoomTicket]>
}

/// Firestore RealTimeDatabase 저장소를 관리하는 서비스
final class DefaultRealTimeDatabaseService: RealTimeDatabaseService {
    let ref: DatabaseReference
    var newMessageHandler: DatabaseHandle?
    
    init() {
        self.ref = Database.database().reference()
    }
    
    // MARK: - 채팅 메시지
    func sendMessage(_ message: ChatMessage) -> Completable {
        Completable.create { [weak self] completable in
            guard let self,
                  let roomID: String = message.chatRoomID,
                  let messageID: String = message.uuid,
                  let messageData: [String: Any] = try? message.encode() else {
                completable(.error(DatabaseError.failedToSend))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.chatRooms.rawValue)
                .child(roomID)
                .child(FirebaseKey.RealtimeDB.chatMessages.rawValue)
                .child(messageID)
                .setValue(messageData)
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func fetchMessages(page: Int, skip: Int, pageCount: Int, roomID: String) -> Single<[ChatMessage]> {
        Single<[ChatMessage]>.create { [weak self] single in
            guard let self else {
                single(.failure(DatabaseError.failedToFetch))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.chatRooms.rawValue)
                .child(roomID)
                .child(FirebaseKey.RealtimeDB.chatMessages.rawValue)
                .queryStarting(atValue: skip)
                .queryLimited(toFirst: UInt(pageCount))
                .observeSingleEvent(of: .value) { snapshot in
                    if let value: [[String: Any]] = snapshot.value as? [[String: Any]] {
                        let chatMessages: [ChatMessage] = value.compactMap({ try? ChatMessage.decode(dictionary: $0) })
                        single(.success(chatMessages))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func observeNewMessage(_ chatRoomID: String) -> Observable<ChatMessage> {
        Observable<ChatMessage>.create { [weak self] observer in
            guard let self else {
                observer.onError(DatabaseError.failedToFetch)
                return Disposables.create()
            }
            
            self.newMessageHandler = self.ref
                .child(FirebaseKey.RealtimeDB.chatRooms.rawValue)
                .child(chatRoomID)
                .child(FirebaseKey.RealtimeDB.chatMessages.rawValue)
                .observe(.childAdded) { (snapshot) -> Void in
                    if let value: [String: Any] = snapshot.value as? [String: Any],
                       let chatMessage: ChatMessage = try? ChatMessage.decode(dictionary: value) {
                        observer.onNext(chatMessage)
                    }
                }
            return Disposables.create()
        }
    }
    
    // MARK: - 채팅방 정보
    func createChatRoom(_ chatRoom: ChatRoom) -> Single<ChatRoom> {
        Single<ChatRoom>.create { [weak self] single in
            guard let self,
                  let uuid: String = chatRoom.uuid,
                  let chatRoomData: [String: Any] = try? chatRoom.encode() else {
                single(.failure(DatabaseError.failedToFetch))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.chatRooms.rawValue)
                .child(uuid)
                .setValue(chatRoomData)

            single(.success(chatRoom))
            return Disposables.create()
        }
    }
    
    func fetchChatRoomInfo(_ chatRoomID: String) -> Single<ChatRoom> {
        Single<ChatRoom>.create { [weak self] single in
            guard let self else {
                single(.failure(DatabaseError.failedToFetch))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.chatRooms.rawValue)
                .child(chatRoomID)
                .observeSingleEvent(of: .value) { snapshot in
                    if let value: [String: Any] = snapshot.value as? [String: Any],
                       let chatRoom: ChatRoom = try? ChatRoom.decode(dictionary: value) {
                        single(.success(chatRoom))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func observeChatRoomInfo(_ chatRoomID: String) -> Observable<ChatRoom> {
        Observable<ChatRoom>.create { [weak self] observable in
            guard let self else {
                observable.onError(DatabaseError.failedToFetch)
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.chatRooms.rawValue)
                .child(chatRoomID)
                .observe(.value) { snapshot in
                    if let value: [String: Any] = snapshot.value as? [String: Any],
                       let chatRoom: ChatRoom = try? ChatRoom.decode(dictionary: value) {
                        observable.onNext(chatRoom)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    // MARK: 유저-채팅방 티켓 정보
    func createUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Completable {
        Completable.create { [weak self] completable in
            guard let self,
                  let uuid: String = ticket.uuid,
                  let userID: String = ticket.userID,
                  let ticketData: [String: Any] = try? ticket.encode() else {
                completable(.error(DatabaseError.failedToCreate))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.users.rawValue)
                .child(userID)
                .child(FirebaseKey.RealtimeDB.userChatRoomTickets.rawValue)
                .child(uuid)
                .setValue(ticketData)
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func updateUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Completable {
        Completable.create { [weak self] completable in
            guard let self,
                  let uuid: String = ticket.uuid,
                  let userID: String = ticket.userID,
                  let ticketData: [String: Any] = try? ticket.encode() else {
                completable(.error(DatabaseError.failedToCreate))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.users.rawValue)
                .child(userID)
                .child(FirebaseKey.RealtimeDB.userChatRoomTickets.rawValue)
                .child(uuid)
                .updateChildValues(ticketData)
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func fetchUserChatRoomTicketList(_ userID: String) -> Single<[UserChatRoomTicket]> {
        Single<[UserChatRoomTicket]>.create { [weak self] single in
            guard let self else {
                single(.failure(DatabaseError.failedToFetch))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.users.rawValue)
                .child(userID)
                .child(FirebaseKey.RealtimeDB.userChatRoomTickets.rawValue)
                .observeSingleEvent(of: .value) { snapshot in
                    if let value: [[String: Any]] = snapshot.value as? [[String: Any]] {
                        let userChatRoomTicket: [UserChatRoomTicket] = value.compactMap({ try? UserChatRoomTicket.decode(dictionary: $0) })
                        single(.success(userChatRoomTicket))
                    }
                }
            
            return Disposables.create()
        }
    }
}

enum DatabaseError: Error {
    case failedToSend
    case failedToFetch
    case failedToCreate
}
