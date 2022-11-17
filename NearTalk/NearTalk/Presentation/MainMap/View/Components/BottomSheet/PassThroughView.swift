//
//  PassThroughView.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/17.
//

import UIKit

class PassThroughView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        return hitView == self ? nil : hitView
    }
}
