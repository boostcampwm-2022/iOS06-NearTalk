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
        
        displayPriority = .defaultLow
        markerTintColor = UIColor.red
        glyphImage = UIImage(systemName: "figure.2.arms.open")
    }
    
    func insert(coordinator: MainMapCoordinator?) {
        self.coordinator = coordinator
    }
}
