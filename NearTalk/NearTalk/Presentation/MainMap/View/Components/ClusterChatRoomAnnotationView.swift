//
//  ClusterChatRoomnAnnotationView.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/15.
//

import MapKit

final class ClusterChatRoomAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("ClusterChatRoomAnnotationView coder init 에러")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            let totalChatRooms = clusterAnnotation.memberAnnotations.count
            
            if totalChatRooms >= 1 {
                self.image = drawClusterAnnotationImage(count: totalChatRooms)
                self.displayPriority = .defaultLow
            }
        }
    }
    
    private func drawClusterAnnotationImage(count: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        
        return renderer.image { _ in
            UIColor.purple.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40)).fill()
            
            let text = "\(count)"
            let textAttibutes = [
                NSAttributedString.Key.foregroundColor: UIColor.cyan, // 임시 글자 색
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20) // 임시 글자 font
            ]
            let size = text.size(withAttributes: textAttibutes)
            let rect = CGRect(
                x: 20 - size.width / 2,
                y: 20 - size.height / 2,
                width: size.width,
                height: size.height
            )
            text.draw(in: rect, withAttributes: textAttibutes)
        }
    }
}
