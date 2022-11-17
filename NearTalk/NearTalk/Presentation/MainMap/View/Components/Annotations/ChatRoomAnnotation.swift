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
    }
    
    var roomType: RoomType = .group
    
    private var latitude: CLLocationDegrees = 0
    private var longitude: CLLocationDegrees = 0
    
    @objc
    dynamic var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }
}
