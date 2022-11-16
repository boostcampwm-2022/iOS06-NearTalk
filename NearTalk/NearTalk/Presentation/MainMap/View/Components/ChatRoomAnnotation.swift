//
//  ChatRoomAnnotation.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/15.
//

import MapKit

final class ChatRoomAnnotation: NSObject, Decodable, MKAnnotation {
    enum RoomType: Int, Decodable {
        case group
        case dm
    }
    
    var roomType: RoomType = .group
    private var latitude: CLLocationDegrees = 0
    private var longitude: CLLocationDegrees = 0
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
}
