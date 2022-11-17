//
//  UIImageView+Rounded.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/11/17.
//

import UIKit

extension UIImageView {
    func makeRounded() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.height / 2
    }
}
