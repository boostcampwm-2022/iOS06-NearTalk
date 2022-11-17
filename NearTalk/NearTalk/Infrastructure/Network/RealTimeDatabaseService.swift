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
    func sendMessage(_ message: ChatMessage, mediaData: Data?) -> Single<Bool>
    func observeChatRoom(_ chatRoomID: String) -> Observable<[ChatMessage]>
}

/// Firestore RealTimeDatabase 저장소를 관리하는 서비스
final class DefaultRealTimeDatabaseService: RealTimeDatabaseService {
    let ref: DatabaseReference
    var chatRoomHandler: DatabaseHandle?

    init() {
        self.ref = Database.database().reference()
    }
}

// MARK: - 채팅 송수신
extension DefaultRealTimeDatabaseService {
    func sendMessage(_ message: ChatMessage, mediaData: Data? = nil) -> Single<Bool> {
        Single<Bool>.create { [weak self] single in
            guard let self,
                  let roomID: String = message.chatRoomID,
                  let messageID: String = message.messageID
            else { return Disposables.create() }
            
            self.ref
                .child(FirebaseServiceType.RealtimeDB.chatRooms.rawValue)
                .child(roomID)
                .child(FirebaseServiceType.RealtimeDB.chatMessages.rawValue)
                .child(messageID)
                .setValue(message)
            
            single(.success(true))
            
            return Disposables.create()
        }
    }
    
    func observeChatRoom(_ chatRoomID: String) -> Observable<[ChatMessage]> {
        Observable<[ChatMessage]>.create { [weak self] observer in
            guard let self else {
                return Disposables.create()
            }
            
            self.chatRoomHandler = self.ref
                .child(FirebaseServiceType.RealtimeDB.chatRooms.rawValue)
                .child(chatRoomID)
                .observe(.value) { snapshot in
                    guard let value = snapshot.value as? [[String: Any]] else {
                        observer.onError(DatabaseError.failedToFetch)
                        return
                    }
                    
                    #warning("pagination")
                    
                    let conversations: [ChatMessage] = value.compactMap({ dictionary in
                        guard let conversationId = dictionary["id"] as? String,
                              let name = dictionary["name"] as? String,
                              let otherUserEmail = dictionary["other_user_email"] as? String,
                              let latestMessage = dictionary["latest_message"] as? [String: Any],
                              let sent = latestMessage["date"] as? String,
                              let message = latestMessage["message"] as? String,
                              let isRead = latestMessage["is_read"] as? Bool else {
                            return nil
                        }
                        return ChatMessage()
                    })

                    observer.onNext(conversations)
                }
            
            return Disposables.create()
        }
    }
    
    func observeChatRoomList() {
        
    }
}

enum DatabaseError: Error {
    case failedToFetch
}
