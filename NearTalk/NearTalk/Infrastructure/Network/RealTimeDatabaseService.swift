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
    func fetchSingleMessage(messageID: String, roomID: String) -> Single<ChatMessage>
    func fetchMessages(date: Date, pageCount: Int, roomID: String) -> Single<[ChatMessage]>
    func observeNewMessage(_ chatRoomID: String) -> Observable<ChatMessage>
    func deleteChatMessages(_ chatRoomID: String) -> Completable
    
    // MARK: 채팅방 정보
    func createChatRoom(_ chatRoom: ChatRoom) -> Single<ChatRoom>
    func updateChatRoom(_ chatRoom: ChatRoom) -> Single<ChatRoom>
    func increaseChatRoomMessageCount(_ chatRoomID: String) -> Completable
    func fetchChatRoomInfo(_ chatRoomID: String) -> Single<ChatRoom>
    func observeChatRoomInfo(_ chatRoomID: String) -> Observable<ChatRoom>
    func deleteChatRoom(_ chatRoomID: String) -> Completable
    
    // MARK: 유저-채팅방 티켓 정보
    func createUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket>
    func updateUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket>
    func fetchSingleUserChatRoomTicket(_ userID: String, _ roomID: String) -> Single<UserChatRoomTicket>
    func fetchUserChatRoomTicketList(_ userID: String) -> Single<[UserChatRoomTicket]>
    func observeUserChatRoomTicketList(_ userID: String) -> Observable<[UserChatRoomTicket]>
    func observeUserChatRoomTicket(_ userID: String, _ roomID: String) -> Observable<UserChatRoomTicket>
    func deleteUserTicketList(_ userID: String) -> Completable
    func deleteUserTicket(_ userID: String, _ chatRoomID: String) -> Completable
}

// swiftlint:disable: type_body_length
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
                  let messageData: [String: Any] = try? message.encode()
            else {
                completable(.error(DatabaseError.failedToSend))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.chatMessages.rawValue)
                .child(roomID)
                .child(messageID)
                .setValue(messageData)
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func fetchSingleMessage(messageID: String, roomID: String) -> Single<ChatMessage> {
        Single<ChatMessage>.create { [weak self] single in
            guard let self
            else {
                single(.failure(DatabaseError.failedToFetch))
                return Disposables.create()
            }

            self.ref
                .child(FirebaseKey.RealtimeDB.chatMessages.rawValue)
                .child(roomID)
                .child(messageID)
                .observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
                    if let value: [String: Any] = snapshot.value as? [String: Any],
                       let chatMessage: ChatMessage = try? ChatMessage.decode(dictionary: value) {
                        single(.success(chatMessage))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func fetchMessages(date: Date, pageCount: Int, roomID: String) -> Single<[ChatMessage]> {
        Single<[ChatMessage]>.create { [weak self] single in
            guard let self
            else {
                single(.failure(DatabaseError.failedToFetch))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.chatMessages.rawValue)
                .child(roomID)
                .queryOrdered(byChild: "createdAtTimeStamp")
                .queryEnding(beforeValue: date.timeIntervalSince1970)
                .queryLimited(toLast: UInt(pageCount))
                .observeSingleEvent(of: .value) { snapshot in
                    let messages: [ChatMessage] = snapshot.children
                        .compactMap { $0 as? DataSnapshot }
                        .compactMap { $0.value as? [String: Any] }
                        .compactMap { try? ChatMessage.decode(dictionary: $0) }
                    single(.success(messages))
                }
            return Disposables.create()
        }
    }
    
    func observeNewMessage(_ chatRoomID: String) -> Observable<ChatMessage> {
        Observable<ChatMessage>.create { [weak self] observer in
            guard let self
            else {
                observer.onError(DatabaseError.failedToFetch)
                return Disposables.create()
            }
            
            self.newMessageHandler = self.ref
                .child(FirebaseKey.RealtimeDB.chatMessages.rawValue)
                .child(chatRoomID)
                .queryOrdered(byChild: "createdAtTimeStamp")
                .queryLimited(toLast: 1)
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
                  let chatRoomData: [String: Any] = try? chatRoom.encode()
            else {
                single(.failure(DatabaseError.failedToFetch))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.chatRooms.rawValue)
                .child(uuid)
                .child(FirebaseKey.RealtimeDB.chatRoomInfo.rawValue)
                .setValue(chatRoomData)

            single(.success(chatRoom))
            return Disposables.create()
        }
    }
    
    func updateChatRoom(_ chatRoom: ChatRoom) -> Single<ChatRoom> {
        Single<ChatRoom>.create { [weak self] single in
            guard let self,
                  let roomID: String = chatRoom.uuid,
                  let chatRoomData: [String: Any] = try? chatRoom.encode()
            else {
                single(.failure(DatabaseError.failedToFetch))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.chatRooms.rawValue)
                .child(roomID)
                .child(FirebaseKey.RealtimeDB.chatRoomInfo.rawValue)
                .updateChildValues(chatRoomData)

            single(.success(chatRoom))
            return Disposables.create()
        }
    }
    
    func increaseChatRoomMessageCount(_ chatRoomID: String) -> Completable {
        Completable.create { [weak self] completable in
            guard let self
            else {
                completable(.error(DatabaseError.failedToFetch))
                return Disposables.create()
            }
            
             let updates: [String: Any] = ["\(FirebaseKey.RealtimeDB.chatRooms.rawValue)/\(chatRoomID)/\(FirebaseKey.RealtimeDB.chatRoomInfo.rawValue)/messageCount": ServerValue.increment(1)] as [String: Any]
             self.ref.updateChildValues(updates)

            completable(.completed)
            return Disposables.create()
        }
    }
    
    func fetchChatRoomInfo(_ chatRoomID: String) -> Single<ChatRoom> {
        Single<ChatRoom>.create { [weak self] single in
            guard let self
            else {
                single(.failure(DatabaseError.failedToFetch))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.chatRooms.rawValue)
                .child(chatRoomID)
                .child(FirebaseKey.RealtimeDB.chatRoomInfo.rawValue)
                .observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
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
            guard let self
            else {
                observable.onError(DatabaseError.failedToFetch)
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.chatRooms.rawValue)
                .child(chatRoomID)
                .child(FirebaseKey.RealtimeDB.chatRoomInfo.rawValue)
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
    func createUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket> {
        Single<UserChatRoomTicket>.create { [weak self] single in
            guard let self,
                  let roomID: String = ticket.roomID,
                  let userID: String = ticket.userID,
                  let ticketData: [String: Any] = try? ticket.encode()
            else {
                single(.failure(DatabaseError.failedToCreate))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.users.rawValue)
                .child(userID)
                .child(FirebaseKey.RealtimeDB.userChatRoomTickets.rawValue)
                .child(roomID)
                .setValue(ticketData)
            single(.success(ticket))
            return Disposables.create()
        }
    }
    
    func updateUserChatRoomTicket(_ ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket> {
        Single<UserChatRoomTicket>.create { [weak self] single in
            guard let self,
                  let roomID: String = ticket.roomID,
                  let userID: String = ticket.userID,
                  let ticketData: [String: Any] = try? ticket.encode()
            else {
                single(.failure(DatabaseError.failedToCreate))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.users.rawValue)
                .child(userID)
                .child(FirebaseKey.RealtimeDB.userChatRoomTickets.rawValue)
                .child(roomID)
                .updateChildValues(ticketData)
            single(.success(ticket))
            return Disposables.create()
        }
    }
    
    func fetchSingleUserChatRoomTicket(_ userID: String, _ roomID: String) -> Single<UserChatRoomTicket> {
        Single<UserChatRoomTicket>.create { [weak self] single in
            guard let self
            else {
                single(.failure(DatabaseError.failedToFetch))
                return Disposables.create()
            }
            
            self.ref
                .child(FirebaseKey.RealtimeDB.users.rawValue)
                .child(userID)
                .child(FirebaseKey.RealtimeDB.userChatRoomTickets.rawValue)
                .child(roomID)
                .observeSingleEvent(of: .value) { snapshot in
                    if let value: [String: Any] = snapshot.value as? [String: Any],
                       let userChatRoomTicket: UserChatRoomTicket = try? UserChatRoomTicket.decode(dictionary: value) {
                        single(.success(userChatRoomTicket))
                    } else {
                        single(.failure(DatabaseError.failedToFetch))
                    }
                }
            return Disposables.create()
        }
    }
    
    func fetchUserChatRoomTicketList(_ userID: String) -> Single<[UserChatRoomTicket]> {
        Single<[UserChatRoomTicket]>.create { [weak self] single in
            guard let self
            else {
                single(.failure(DatabaseError.failedToFetch))
                return Disposables.create()
            }
            self.ref
                .child(FirebaseKey.RealtimeDB.users.rawValue)
                .child(userID)
                .child(FirebaseKey.RealtimeDB.userChatRoomTickets.rawValue)
                .observeSingleEvent(of: .value) { snapshot in
                    let tickets: [UserChatRoomTicket] = snapshot.children
                        .compactMap { $0 as? DataSnapshot }
                        .compactMap { $0.value as? [String: Any] }
                        .compactMap { try? UserChatRoomTicket.decode(dictionary: $0) }
                
                    single(.success(tickets))
                }
            return Disposables.create()
        }
    }
    
    func observeUserChatRoomTicketList(_ userID: String) -> Observable<[UserChatRoomTicket]> {
        Observable<[UserChatRoomTicket]>.create { [weak self] observable in
            guard let self
            else {
                observable.onError(DatabaseError.failedToFetch)
                return Disposables.create()
            }
            self.ref
                .child(FirebaseKey.RealtimeDB.users.rawValue)
                .child(userID)
                .child(FirebaseKey.RealtimeDB.userChatRoomTickets.rawValue)
                .observe(.value) { snapshot in
                    let tickets: [UserChatRoomTicket] = snapshot.children
                        .compactMap { $0 as? DataSnapshot }
                        .compactMap { $0.value as? [String: Any] }
                        .compactMap { try? UserChatRoomTicket.decode(dictionary: $0) }
                
                    observable.onNext(tickets)
                    
                }
            return Disposables.create()
        }
    }
    
    func observeUserChatRoomTicket(_ userID: String, _ roomID: String) -> Observable<UserChatRoomTicket> {
        Observable<UserChatRoomTicket>.create { [weak self] observable in
            guard let self
            else {
                observable.onError(DatabaseError.failedToFetch)
                return Disposables.create()
            }
            self.ref
                .child(FirebaseKey.RealtimeDB.users.rawValue)
                .child(userID)
                .child(FirebaseKey.RealtimeDB.userChatRoomTickets.rawValue)
                .child(roomID)
                .observe(.value) { snapshot in
                    if let value: [String: Any] = snapshot.value as? [String: Any],
                       let ticket: UserChatRoomTicket = try? UserChatRoomTicket.decode(dictionary: value) {
                        observable.onNext(ticket)
                    }
                }
            return Disposables.create()
        }
    }
    
    func deleteUserTicketList(_ userID: String) -> Completable {
        Completable.create { [weak self] completable in
            self?.ref
                .child(FirebaseKey.RealtimeDB.users.rawValue)
                .child(userID)
                .removeValue(completionBlock: { error, _ in
                    if let error = error {
                        completable(.error(error))
                    } else {
                        completable(.completed)
                    }
                })
            return Disposables.create()
        }
    }
    
    func deleteUserTicket(_ userID: String, _ chatRoomID: String) -> Completable {
        Completable.create { [weak self] completable in
            self?.ref
                .child(FirebaseKey.RealtimeDB.users.rawValue)
                .child(userID)
                .child(FirebaseKey.RealtimeDB.userChatRoomTickets.rawValue)
                .child(chatRoomID)
                .removeValue(completionBlock: { error, _ in
                    if let error = error {
                        completable(.error(error))
                    } else {
                        completable(.completed)
                    }
                })
            return Disposables.create()
        }
    }
    
    func deleteChatRoom(_ chatRoomID: String) -> Completable {
        Completable.create { [weak self] completable in
            self?.ref
                .child(FirebaseKey.RealtimeDB.chatRooms.rawValue)
                .child(chatRoomID)
                .removeValue(completionBlock: { error, _ in
                    if let error = error {
                        completable(.error(error))
                    } else {
                        completable(.completed)
                    }
                })
            return Disposables.create()
        }
    }
    
    func deleteChatMessages(_ chatRoomID: String) -> Completable {
        Completable.create { [weak self] completable in
            self?.ref
                .child(FirebaseKey.RealtimeDB.chatMessages.rawValue)
                .child(chatRoomID)
                .removeValue(completionBlock: { error, _ in
                    if let error = error {
                        completable(.error(error))
                    } else {
                        completable(.completed)
                    }
                })
            return Disposables.create()
        }
    }
}

enum DatabaseError: Error {
    case failedToSend
    case failedToFetch
    case failedToCreate
    case failedToDecode
}
