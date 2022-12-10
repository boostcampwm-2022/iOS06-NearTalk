//
//  ChatRoomOpenAnnotationView.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/15.
//

import MapKit

final class GroupChatRoomAnnotationView: MKMarkerAnnotationView {
    
    static let reuseIdentifier = String(describing: GroupChatRoomAnnotationView.self)
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let value = newValue as? ChatRoomAnnotation
            else { return }
            
            self.canShowCallout = true
            self.detailCalloutAccessoryView = CalloutView(annotation: value, coordinator: self.coordinator)
        }
    }
    
    private var coordinator: MainMapCoordinator?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.clusteringIdentifier = ChatRoomClusterAnnotationView.reuseIdentifier
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        self.displayPriority = .defaultLow
        self.glyphImage = UIImage(systemName: "figure.2.arms.open")
        self.markerTintColor = self.isAccessible() ? .red : .gray
        self.canShowCallout = self.markerTintColor == .red
        self.isEnabled = self.markerTintColor == .red
    }
    
    func insert(coordinator: MainMapCoordinator?) {
        self.coordinator = coordinator
    }
    
    private func isAccessible() -> Bool {
        guard let annotation = self.annotation as? ChatRoomAnnotation,
              let chatRoomLatitude = annotation.chatRoomInfo.latitude,
              let chatRoomLongitude = annotation.chatRoomInfo.longitude,
              let chatRoomAccessibleRadius = annotation.chatRoomInfo.accessibleRadius
        else { return false }
        
        let userNCLocation = annotation.userLocation
        let chatRoomLocation = NCLocation(latitude: chatRoomLatitude, longitude: chatRoomLongitude)
        let chatRoomAccessibleRadiusMeters = chatRoomAccessibleRadius * 1000
        
        return chatRoomLocation.distance(from: userNCLocation) <= 500
    }
}
