//
//  ClusterChatRoomnAnnotationView.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/15.
//

import MapKit

final class ChatRoomClusterAnnotationView: MKAnnotationView {
    static let reuseIdentifier = String(describing: ChatRoomClusterAnnotationView.self)
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.collisionMode = .circle
        self.centerOffset = CGPoint(x: 0, y: -10)
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
        let magnificationPerCount: Double = 5
        let maxClusterMembersCount: Int = 10
        let width: CGFloat = .init(24 + Double(min(count, maxClusterMembersCount)) * magnificationPerCount)
        let height: CGFloat = .init(24 + Double(min(count, maxClusterMembersCount)) * magnificationPerCount)
        let lineWidth: CGFloat = .init(3)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        
        return renderer.image { _ in
            // 최외각 원 그리기
            UIColor.whiteLabel?
                .withAlphaComponent(0.5)
                .setFill()
            
            UIBezierPath(ovalIn: CGRect(x: 0,
                                        y: 0,
                                        width: width,
                                        height: height)).fill()
            
            // 내부 원 그리기
            UIColor.secondaryColor?
                // maxClusterMembers개 이상부터, 투명도 1 이상
                .withAlphaComponent(0.5 + (Double(count) / Double(count + maxClusterMembersCount)))
                .setFill()
            
            UIBezierPath(ovalIn: CGRect(x: lineWidth,
                                        y: lineWidth,
                                        width: width - (2 * lineWidth),
                                        height: height - (2 * lineWidth))).fill()
            
            // 텍스트 작성
            let text = "\(count)"
            let textAttibutes = [
                NSAttributedString.Key.foregroundColor: UIColor.whiteLabel,
                NSAttributedString.Key.font: UIFont.ntTextLargeRegular
            ]
            
            let size = text.size(withAttributes: textAttibutes as [NSAttributedString.Key: Any])
            let rect = CGRect(x: (width - size.width) / 2,
                              y: (height - size.height) / 2,
                              width: size.width,
                              height: size.height)
            
            text.draw(in: rect, withAttributes: textAttibutes as [NSAttributedString.Key: Any])
        }
    }
}
