//
//  ChatRoomDmAnnotationView.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/15.
//

import MapKit

final class DmChatRoomAnnotationView: MKMarkerAnnotationView {
    static let reuseIdentifier = "DmChatRoomAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        clusteringIdentifier = "ChatRoomClustering"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultLow
        markerTintColor = UIColor.blue // 임시 색상
        glyphImage = UIImage(systemName: "figure.wave") // 임시 이미지
    }
}
