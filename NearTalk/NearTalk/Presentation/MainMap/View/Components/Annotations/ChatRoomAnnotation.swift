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
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    @objc
    dynamic var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(chatRoomInfo: ChatRoom, roomType: RoomType, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.chatRoomInfo = chatRoomInfo
        self.roomType = roomType
        self.latitude = latitude
        self.longitude = longitude
    }
    
    static func create(with chatRoomInfo: ChatRoom) -> ChatRoomAnnotation? {
        guard let roomType: ChatRoomAnnotation.RoomType = chatRoomInfo.roomType == RoomType.group.name ? .group : .directMessage,
              let latitude = chatRoomInfo.latitude,
              let longitude = chatRoomInfo.longitude
        else { return nil }
        
        return ChatRoomAnnotation(chatRoomInfo: chatRoomInfo,
                                  roomType: roomType,
                                  latitude: latitude,
                                  longitude: longitude)
    }
}
