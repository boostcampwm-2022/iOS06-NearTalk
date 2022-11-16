//
//  ChatRoomOpenAnnotationView.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/15.
//

import MapKit

final class GroupChatRoomAnnotationView: MKMarkerAnnotationView {
    static let reuseIdentifier = "OpenChatRoomAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        // clusteringIdentifier = "clustering"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultLow
        markerTintColor = UIColor.red // 임시 색상
        glyphImage = UIImage(systemName: "figure.2.arms.open") // 임시 이미지
    }
}
