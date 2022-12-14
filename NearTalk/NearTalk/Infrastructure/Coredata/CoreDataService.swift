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
    func fetchMessage(_ uuid: String) -> Single<ChatMessage>
    func fetchMessageList(roomID: String, before date: Date, limit: Int) -> Single<[ChatMessage]>
    func fetchFriend(_ uuid: String) -> Single<UserProfile>
    func fetchFriendList() -> Single<[UserProfile]>
    func fetchChatRoom(_ roomID: String) -> Single<ChatRoom>
    func fetchChatRoomList() -> Single<[ChatRoom]>
    func fetchTicket(_ ticketID: String) -> Single<UserChatRoomTicket>
    func fetchTicketList() -> Single<[UserChatRoomTicket]>
    
    func saveMessage(_ message: ChatMessage) -> Completable
    func saveMessageList(_ messageList: [ChatMessage]) -> Completable
    func saveFriend(_ profile: UserProfile) -> Completable
    func saveChatRoom(_ room: ChatRoom) -> Completable
    func saveTicket(_ ticket: UserChatRoomTicket) -> Completable

    func updateMessage(_ message: ChatMessage) -> Single<ChatMessage>
    func updateFriend(_ profile: UserProfile) -> Single<UserProfile>
    func updateChatRoom(_ room: ChatRoom) -> Single<ChatRoom>
    func updateTicket(_ ticket: UserChatRoomTicket) -> Single<UserChatRoomTicket>

    func deleteMessage(_ uuid: String) -> Completable
    func deleteMessageList(_ uuidList: [String]) -> Completable
    func deleteFriend(_ uuid: String) -> Completable
    func deleteChatRoom(_ uuid: String) -> Completable
    func deleteTicket(_ uuid: String) -> Completable
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
        let beforeDate: NSNumber = NSNumber(value: date.timeIntervalSince1970)
        let predicate: NSPredicate = .init(format: "createdAtTimeStamp < %@ AND chatRoomID == %@", beforeDate, roomID)
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
        return self.saveObject(entityKey: .message, data: message, type: CDChatMessage.self)
    }
    
    func saveMessageList(_ messageList: [ChatMessage]) -> Completable {
        self.saveObjectList(entityKey: .message, dataList: messageList, type: CDChatMessage.self)
    }
    
    func saveFriend(_ profile: UserProfile) -> Completable {
        self.saveObject(entityKey: .userProfile, data: profile, type: CDUserProfile.self)
    }
    
    func saveChatRoom(_ room: ChatRoom) -> Completable {
        self.saveObject(entityKey: .chatRoom, data: room, type: CDChatRoom.self)
    }
    
    func saveTicket(_ ticket: UserChatRoomTicket) -> Completable {
        self.saveObject(entityKey: .userChatRoomTicket, data: ticket, type: CDUserChatRoomTicket.self)
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
    private func fetchObject<T: BaseEntity>(with uuid: String, entityKey: CoreDataEntityKey) -> Single<T> {
        Single<T>.create { [weak self] single in
            guard let self
            else {
                single(.failure(CoreDataServiceError.failedToFetch))
                return Disposables.create()
            }
            let predicate: NSPredicate = .init(format: "id == %@", uuid)
            let fetchRequest: NSFetchRequest<NSManagedObject> = self.getRequest(entityKey, predicate, 1)
            if let fetchResult: [NSManagedObject] = try? self.persistentContainer.viewContext.fetch(fetchRequest),
               fetchResult.count == 1,
               let result: T = entityKey.getObject(object: fetchResult.first!) as? T {
                single(.success(result))
            } else {
                single(.failure(CoreDataServiceError.failedToFetch))
            }
            return Disposables.create()
        }
    }
    
    private func fetchObjectList<T: BaseEntity>(entityKey: CoreDataEntityKey, predicate: NSPredicate, limit: Int) -> Single<[T]> {
        Single<[T]>.create { [weak self] single in
            guard let self
            else {
                single(.failure(CoreDataServiceError.failedToFetch))
                return Disposables.create()
            }
            let fetchRequest: NSFetchRequest<NSManagedObject> = self.getRequest(entityKey, predicate, limit)
            do {
                let objects: [NSManagedObject] = try self.persistentContainer.viewContext.fetch(fetchRequest)
                var result: [T] = []
                objects.forEach { object in
                    if let obj = entityKey.getObject(object: object) as? T {
                        result.append(obj)
                    }
                }
                single(.success(result))
            } catch let error {
                print("🔥 ", error)
                single(.failure(CoreDataServiceError.failedToFetch))
            }
            return Disposables.create()
        }
    }
    
    private func saveObject<T: BaseEntity, U: NSManagedObject>(entityKey: CoreDataEntityKey, data: T, type: U.Type) -> Completable {
        Completable.create { [weak self] completable in
            guard let self,
                  let entity: NSEntityDescription = self.getEntity(entityKey: entityKey, query: .modify)
            else {
                completable(.error(CoreDataServiceError.failedToSave))
                return Disposables.create()
            }
            
            let newObject: U = U(entity: entity, insertInto: self.backgroundContext)
            entityKey.setObject(object: newObject, data)
            do {
                try self.backgroundContext.save()
                completable(.completed)
            } catch let error {
                print("🔥 error", error)
                completable(.error(CoreDataServiceError.failedToSave))
            }
            return Disposables.create()
        }
    }
    
    private func saveObjectList<T: BaseEntity, U: NSManagedObject>(entityKey: CoreDataEntityKey, dataList: [T], type: U.Type) -> Completable {
        Completable.create { [weak self] completable in
            guard let self,
                  let entity: NSEntityDescription = self.getEntity(entityKey: entityKey, query: .modify)
            else {
                completable(.error(CoreDataServiceError.failedToSave))
                return Disposables.create()
            }
            dataList.forEach { data in
                let newObject: U = U(entity: entity, insertInto: self.backgroundContext)
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
        let fetchRequest: NSFetchRequest<NSManagedObject> = .init(entityName: entityKey.entityName)
        fetchRequest.fetchLimit = limit
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    private func getEntity(entityKey: CoreDataEntityKey, query: CoreDataQueryType) -> NSEntityDescription? {
        print("🚧 entityKey.entityName", entityKey.entityName)
        return NSEntityDescription.entity(
            forEntityName: entityKey.entityName,
            in: query == .fetch ? self.persistentContainer.viewContext : self.backgroundContext
        )
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
