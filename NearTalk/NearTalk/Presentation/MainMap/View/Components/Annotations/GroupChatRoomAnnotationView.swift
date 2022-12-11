//
//  ChatRoomOpenAnnotationView.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/15.
//

import MapKit

final class GroupChatRoomAnnotationView: MKMarkerAnnotationView {
    
    private enum Accessible: Int {
        case allowed
        case notAllowed
        
        var bool: Bool {
            switch self {
            case .allowed:
                return true
            case .notAllowed:
                return false
            }
        }
        
        var color: UIColor {
            switch self {
            case .allowed:
                return .red
            case .notAllowed:
                return .blue
            }
        }
    }
    
    static let reuseIdentifier = String(describing: GroupChatRoomAnnotationView.self)
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let value = newValue as? ChatRoomAnnotation
            else { return }
            
            self.detailCalloutAccessoryView = CalloutView(annotation: value, coordinator: self.coordinator)
            self.canShowCallout = self.isAccessible.bool
        }
    }
    
    private var coordinator: MainMapCoordinator?
    private var isAccessible: Accessible = .notAllowed
    
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
        self.markerTintColor = self.isAccessible.color
        self.canShowCallout = self.isAccessible.bool
    }
    
    func insert(coordinator: MainMapCoordinator?) {
        self.coordinator = coordinator
    }
    
    func configureAccessible(userLocation: NCLocation, targetAnnotation: MKAnnotation) {
        guard let targetAnnotation = targetAnnotation as? ChatRoomAnnotation,
              let accessibleRadius = targetAnnotation.chatRoomInfo.accessibleRadius
        else { return }
        
        let targetNCLocation = NCLocation(latitude: targetAnnotation.coordinate.latitude,
                                          longitude: targetAnnotation.coordinate.longitude)
        
        self.isAccessible = targetNCLocation.distance(from: userLocation) < accessibleRadius * 1000 ? .allowed : .notAllowed
        self.markerTintColor = self.isAccessible.color
        self.canShowCallout = self.isAccessible.bool
    }
}
