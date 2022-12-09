//
//  ChatRoomAnnotation.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/15.
//

import MapKit

final class ChatRoomAnnotation: NSObject, Decodable, MKAnnotation {
    enum RoomType: Int, Decodable, CaseIterable {
        case group
        case directMessage
        
        var name: String {
            switch self {
            case .group:
                return "group"
            case .directMessage:
                return "directMessage"
            }
        }
    }
    
    let chatRoomInfo: ChatRoom
    let roomType: RoomType
    var isAccessible: Bool = false
    @objc
    dynamic var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.chatRoomInfo.latitude ?? 0,
                                      longitude: self.chatRoomInfo.longitude ?? 0)
    }
    
    init(chatRoomInfo: ChatRoom) {
        self.chatRoomInfo = chatRoomInfo
        self.roomType = self.chatRoomInfo.roomType == RoomType.group.name ? .group : .directMessage
    }
    
    static func create(with chatRoomInfo: ChatRoom) -> ChatRoomAnnotation? {
        return ChatRoomAnnotation(chatRoomInfo: chatRoomInfo)
    }
}
