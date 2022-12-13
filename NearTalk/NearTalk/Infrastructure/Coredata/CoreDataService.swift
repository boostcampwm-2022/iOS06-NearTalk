//
//  CoreDataService.swift
//  NearTalk
//
//  Created by 고병학 on 2022/12/03.
//

import CoreData
import Foundation
import RxSwift

protocol CoreDataService {
    
}

final class DefaultCoreDataService: CoreDataService {
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NearTalk")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let newBackgroundContext = self.persistentContainer.newBackgroundContext()
        newBackgroundContext.automaticallyMergesChangesFromParent = true
        return newBackgroundContext
    }()
    
    // MARK: - Fetch
    func fetchMessage(_ uuid: String) -> Single<ChatMessage> {
        return self.fetchObject(with: uuid, entityKey: .message)
    }
    
    func fetchMessageList(roomID: String, before date: Date, limit: Int = 30) -> Single<[ChatMessage]> {
        let beforeDate: NSDate = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
        let predicate: NSPredicate = .init(format: "createdAt < %@ AND chatRoomID == %@", beforeDate, roomID)
        return self.fetchObjectList(entityKey: .message, predicate: predicate, limit: limit)
    }
    
    func fetchFriend(_ uuid: String) -> Single<UserProfile> {
        self.fetchObject(with: uuid, entityKey: .userProfile)
    }
    
    func fetchFriendList() -> Single<[UserProfile]> {
        self.fetchObjectList(entityKey: .userProfile, predicate: .init(), limit: .max)
    }
    
    func fetchChatRoom(_ roomID: String) -> Single<ChatRoom> {
        self.fetchObject(with: roomID, entityKey: .chatRoom)
    }
    
    func fetchChatRoomList() -> Single<[ChatRoom]> {
        self.fetchObjectList(entityKey: .chatRoom, predicate: .init(), limit: .max)
    }

    func fetchTicket(_ ticketID: String) -> Single<UserChatRoomTicket> {
        self.fetchObject(with: ticketID, entityKey: .userChatRoomTicket)
    }
    
    func fetchTicketList() -> Single<[UserChatRoomTicket]> {
        self.fetchObjectList(entityKey: .userChatRoomTicket, predicate: .init(), limit: .max)
    }
    
    // MARK: - Save
    func saveMessage(_ message: ChatMessage) -> Completable {
        self.saveObject(entityKey: .message, data: message)
    }
    
    func saveMessageList(_ messageList: [ChatMessage]) -> Completable {
        self.saveObjectList(entityKey: .message, dataList: messageList)
    }
    
    func saveFriend(_ profile: UserProfile) -> Completable {
        self.saveObject(entityKey: .userProfile, data: profile)
    }
    
    func saveChatRoom(_ room: ChatRoom) -> Completable {
        self.saveObject(entityKey: .chatRoom, data: room)
    }
    
    func saveTicket(_ ticket: UserChatRoomTicket) -> Completable {
        self.saveObject(entityKey: .userChatRoomTicket, data: ticket)
    }
    
    // MARK: - Update
    func updateMessage(_ message: ChatMessage) -> Single<ChatMessage> {
        self.updateObject(entityKey: .message, data: message)
    }
    
    func updateFriend(_ profile: UserProfile) -> Single<UserProfile> {
        self.updateObject(entityKey: .userProfile, data: profile)
    }
    
    func updateChatRoom(_ room: ChatRoom) -> Single<ChatRoom> {
        self.updateObject(entityKey: .chatRoom, data: room)
    }
    
    func updateTicket(_ ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket> {
        self.updateObject(entityKey: .userChatRoomTicket, data: ticket)
    }
    
    // MARK: - Delete
    func deleteMessage(_ uuid: String) -> Completable {
        self.deleteObject(entityKey: .message, uuid: uuid)
    }
    
    func deleteMessageList(_ uuidList: [String]) -> Completable {
        Completable.concat(uuidList.map { self.deleteObject(entityKey: .chatRoom, uuid: $0) })
    }
    
    func deleteFriend(_ uuid: String) -> Completable {
        self.deleteObject(entityKey: .userProfile, uuid: uuid)
    }
    
    func deleteChatRoom(_ uuid: String) -> Completable {
        self.deleteObject(entityKey: .chatRoom, uuid: uuid)
    }
    
    func deleteTicket(_ uuid: String) -> Completable {
        self.deleteObject(entityKey: .userChatRoomTicket, uuid: uuid)
    }
    
    // MARK: - Private
    private func fetchObject<T>(with uuid: String, entityKey: CoreDataEntityKey) -> Single<T> {
        Single<T>.create { [weak self] single in
            guard let self
            else {
                single(.failure(CoreDataServiceError.failedToFetch))
                return Disposables.create()
            }
            let predicate: NSPredicate = .init(format: "uuid == %@", uuid)
            let fetchRequest: NSFetchRequest<NSManagedObject> = self.getRequest(entityKey, predicate, 1)
            if let fetchResult: [T] = try? self.persistentContainer.viewContext.fetch(fetchRequest) as? [T],
               fetchResult.count == 1 {
                print(fetchResult.first!)
                single(.success(fetchResult.first!))
            } else {
                print("🔴 Could not fetch")
                single(.failure(CoreDataServiceError.failedToFetch))
            }
            return Disposables.create()
        }
    }
    
    private func fetchObjectList<T: BaseEntity>(entityKey: CoreDataEntityKey, predicate: NSPredicate, limit: Int) -> Single<[T]> {
        Single<[T]>.create { [weak self] single in
            guard let self
            else {
                print("🔥 CoreDataServiceError.failedToFetch")
                single(.failure(CoreDataServiceError.failedToFetch))
                return Disposables.create()
            }
            print("🟢", #function)
            let fetchRequest: NSFetchRequest<NSManagedObject> = self.getRequest(entityKey, predicate, limit)
            do {
                if let fetchResult: [T] = try self.persistentContainer.viewContext.fetch(fetchRequest) as? [T] {
                    single(.success(fetchResult))
                } else {
                    single(.failure(CoreDataServiceError.failedToDecode))
                }
            } catch let error {
                print("🔥 ", error)
                single(.failure(CoreDataServiceError.failedToFetch))
            }
            return Disposables.create()
        }
    }
    
    private func saveObject<T: BaseEntity>(entityKey: CoreDataEntityKey, data: T) -> Completable {
        Completable.create { [weak self] completable in
            guard let self,
                  let entity: NSEntityDescription = self.getEntity(entityKey: entityKey, query: .modify)
            else {
                print("🔥 fail?")
                completable(.error(CoreDataServiceError.failedToSave))
                return Disposables.create()
            }
            let newObject: NSManagedObject = NSManagedObject(entity: entity, insertInto: self.backgroundContext)
            entityKey.setObject(object: newObject, data)
            print("🔥 ", newObject.value(forKey: "uuid"))
            do {
                try self.backgroundContext.save()
                completable(.completed)
            } catch let error {
                print(error)
                completable(.error(CoreDataServiceError.failedToSave))
            }
            return Disposables.create()
        }
    }
    
    private func saveObjectList<T: BaseEntity>(entityKey: CoreDataEntityKey, dataList: [T]) -> Completable {
        Completable.create { [weak self] completable in
            guard let self,
                  let entity: NSEntityDescription = self.getEntity(entityKey: entityKey, query: .modify)
            else {
                completable(.error(CoreDataServiceError.failedToSave))
                return Disposables.create()
            }
            dataList.forEach { data in
                let newObject: NSManagedObject = NSManagedObject(entity: entity, insertInto: self.backgroundContext)
                entityKey.setObject(object: newObject, data)
            }
            do {
                try self.backgroundContext.save()
                completable(.completed)
            } catch let error {
                print(error)
                completable(.error(CoreDataServiceError.failedToSave))
            }
            return Disposables.create()
        }
    }
    
    private func updateObject<T: BaseEntity>(entityKey: CoreDataEntityKey, data: T) -> Single<T> {
        Single<T>.create { [weak self] single in
            guard let self,
                  let uuid = data.uuid
            else {
                single(.failure(CoreDataServiceError.failedToUpdate))
                return Disposables.create()
            }
            let predicate: NSPredicate = .init(format: "uuid == %@", uuid)
            let fetchRequest: NSFetchRequest<NSManagedObject> = self.getRequest(entityKey, predicate, 1)
            if let objectUpdate: NSManagedObject = try? self.persistentContainer.viewContext.fetch(fetchRequest).first {
                entityKey.setObject(object: objectUpdate, data)
                do {
                    try self.persistentContainer.viewContext.save()
                    single(.success(data))
                } catch {
                    print(error)
                    single(.failure(CoreDataServiceError.failedToUpdate))
                }
            } else {
                print("🔴 Could not update")
                single(.failure(CoreDataServiceError.failedToUpdate))
            }
            return Disposables.create()
        }
    }
    
    private func deleteObject(entityKey: CoreDataEntityKey, uuid: String) -> Completable {
        Completable.create { [weak self] completable in
            guard let self
            else {
                completable(.error(CoreDataServiceError.failedToDelete))
                return Disposables.create()
            }
            let predicate: NSPredicate = .init(format: "uuid == %@", uuid)
            let fetchRequest: NSFetchRequest<NSManagedObject> = self.getRequest(entityKey, predicate, 1)
            if let objectDelete: NSManagedObject = try? self.persistentContainer.viewContext.fetch(fetchRequest).first {
                self.backgroundContext.delete(objectDelete)
                do {
                    try self.persistentContainer.viewContext.save()
                    completable(.completed)
                } catch let error {
                    print(error)
                    completable(.error(CoreDataServiceError.failedToDelete))
                }
            } else {
                print("🔴 Could not delete")
                completable(.error(CoreDataServiceError.failedToDelete))
            }
            return Disposables.create()
        }
    }
    
    private func getRequest(_ entityKey: CoreDataEntityKey, _ predicate: NSPredicate, _ limit: Int) -> NSFetchRequest<NSManagedObject> {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: entityKey.entityName)
        fetchRequest.fetchLimit = limit
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    private func getEntity(entityKey: CoreDataEntityKey, query: CoreDataQueryType) -> NSEntityDescription? {
        return NSEntityDescription.entity(
            forEntityName: entityKey.entityName,
            in: query == .fetch ? self.persistentContainer.viewContext : self.backgroundContext
        )
    }
}

// MARK: - CoreDataEntityKey
enum CoreDataEntityKey: String {
    case userProfile
    case message
    case chatRoom
    case userChatRoomTicket
    
    var entityName: String {
        switch self {
        case .userProfile:
            return "CDUserProfile"
        case .message:
            return "CDChatMessage"
        case .chatRoom:
            return "CDChatRoom"
        case .userChatRoomTicket:
            return "CDUserChatRoomTicket"
        }
    }
    
    func setObject(object: NSManagedObject, _ data: BaseEntity) {
        switch self {
        case .userProfile:
            guard let profileData: UserProfile = data as? UserProfile
            else {
                return
            }
            self.setUserProfileData(object, profileData)
        case .message:
            guard let messageData: ChatMessage = data as? ChatMessage
            else {
                return
            }
            self.setMessageData(object, messageData)
        case .chatRoom:
            guard let chatRoomData: ChatRoom = data as? ChatRoom
            else {
                return
            }
            self.setChatRoomData(object, chatRoomData)
        case .userChatRoomTicket:
            guard let ticketData: UserChatRoomTicket = data as? UserChatRoomTicket
            else {
                return
            }
            self.setUserChatRoomTicket(object, ticketData)
        }
    }
    
    private func setUserProfileData(_ object: NSManagedObject, _ profile: UserProfile) {
        object.setValue(profile.uuid, forKey: "uuid")
        object.setValue(profile.username, forKey: "username")
        object.setValue(profile.email, forKey: "email")
        object.setValue(profile.statusMessage, forKey: "statusMessage")
        object.setValue(profile.profileImagePath, forKey: "profileImagePath")
        object.setValue(profile.friends, forKey: "friends")
        object.setValue(profile.chatRooms, forKey: "chatRooms")
        object.setValue(profile.fcmToken, forKey: "fcmToken")
    }
    
    private func setMessageData(_ object: NSManagedObject, _ message: ChatMessage) {
        object.setValue(message.uuid, forKey: "uuid")
        object.setValue(message.chatRoomID, forKey: "chatRoomID")
        object.setValue(message.senderID, forKey: "senderID")
        object.setValue(message.text, forKey: "text")
        object.setValue(message.messageType, forKey: "messageType")
        object.setValue(message.mediaPath, forKey: "mediaPath")
        object.setValue(message.mediaType, forKey: "mediaType")
        object.setValue(message.createdAtTimeStamp, forKey: "createdAtTimeStamp")
    }
    
    private func setChatRoomData(_ object: NSManagedObject, _ chatRoom: ChatRoom) {
        object.setValue(chatRoom.uuid, forKey: "uuid")
        object.setValue(chatRoom.roomName, forKey: "roomName")
        object.setValue(chatRoom.roomImagePath, forKey: "roomImagePath")
        object.setValue(chatRoom.roomType, forKey: "roomType")
    }
    
    private func setUserChatRoomTicket(_ object: NSManagedObject, _ ticket: UserChatRoomTicket) {
        object.setValue(ticket.uuid, forKey: "uuid")
        object.setValue(ticket.userID, forKey: "userID")
        object.setValue(ticket.roomID, forKey: "roomID")
        object.setValue(ticket.lastReadMessageID, forKey: "lastReadMessageID")
        object.setValue(ticket.lastRoomMessageCount, forKey: "lastRoomMessageCount")
    }
}

// MARK: - CoreDataQueryType
enum CoreDataQueryType {
    case fetch
    case modify
}

// MARK: - CoreDataServiceError
enum CoreDataServiceError: Error {
    case failedToFetch
    case failedToSave
    case failedToUpdate
    case failedToDelete
    case failedToDecode
}
