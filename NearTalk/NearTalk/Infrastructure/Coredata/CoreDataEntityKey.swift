//
//  CoreDataEntityKey.swift
//  NearTalk
//
//  Created by 고병학 on 2022/12/13.
//

import CoreData
import Foundation

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
    
    func getObject(object: NSManagedObject) -> BaseEntity {
        switch self {
        case .userProfile:
            return self.getUserProfileData(object)
        case .message:
            return self.getMessageData(object)
        case .chatRoom:
            return self.getChatRoomData(object)
        case .userChatRoomTicket:
            return self.getUserChatRoomTicket(object)
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
        object.setValue(message.uuid ?? "", forKey: "id")
        object.setValue(message.chatRoomID ?? "", forKey: "chatRoomID")
        object.setValue(message.senderID ?? "", forKey: "senderID")
        object.setValue(message.text ?? "", forKey: "text")
        object.setValue(message.messageType ?? "", forKey: "messageType")
        object.setValue(message.mediaPath ?? "", forKey: "mediaPath")
        object.setValue(message.mediaType ?? "", forKey: "mediaType")
        object.setValue(message.createdAtTimeStamp ?? 0.0, forKey: "createdAtTimeStamp")
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
    
    private func getUserProfileData(_ object: NSManagedObject) -> BaseEntity {
//        object.setValue(profile.uuid, forKey: "uuid")
//        object.setValue(profile.username, forKey: "username")
//        object.setValue(profile.email, forKey: "email")
//        object.setValue(profile.statusMessage, forKey: "statusMessage")
//        object.setValue(profile.profileImagePath, forKey: "profileImagePath")
//        object.setValue(profile.friends, forKey: "friends")
//        object.setValue(profile.chatRooms, forKey: "chatRooms")
//        object.setValue(profile.fcmToken, forKey: "fcmToken")
        return UserProfile()
    }
    
    private func getMessageData(_ object: NSManagedObject) -> BaseEntity {
        return ChatMessage(
            uuid: object.value(forKey: "id") as? String,
            chatRoomID: object.value(forKey: "chatRoomID") as? String,
            senderID: object.value(forKey: "senderID") as? String,
            text: object.value(forKey: "text") as? String,
            messageType: object.value(forKey: "messageType") as? String,
            mediaPath: object.value(forKey: "mediaPath") as? String,
            mediaType: object.value(forKey: "mediaType") as? String,
            createdAtTimeStamp: object.value(forKey: "createdAtTimeStamp") as? Double
        )
    }
    
    private func getChatRoomData(_ object: NSManagedObject) -> BaseEntity {
//        object.setValue(chatRoom.uuid, forKey: "uuid")
//        object.setValue(chatRoom.roomName, forKey: "roomName")
//        object.setValue(chatRoom.roomImagePath, forKey: "roomImagePath")
//        object.setValue(chatRoom.roomType, forKey: "roomType")
        return ChatRoom(latitude: 0, longitude: 0)
    }
    
    private func getUserChatRoomTicket(_ object: NSManagedObject) -> BaseEntity {
//        object.setValue(ticket.uuid, forKey: "uuid")
//        object.setValue(ticket.userID, forKey: "userID")
//        object.setValue(ticket.roomID, forKey: "roomID")
//        object.setValue(ticket.lastReadMessageID, forKey: "lastReadMessageID")
//        object.setValue(ticket.lastRoomMessageCount, forKey: "lastRoomMessageCount")
        return UserChatRoomTicket()
    }
}
