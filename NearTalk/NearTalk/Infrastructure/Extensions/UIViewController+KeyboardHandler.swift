//
//  UIViewController+KeyboardHandler.swift
//  NearTalk
//
//  Created by Preston Kim on 2022/12/05.
//

import UIKit

typealias KeyboardPopInfo = (frame: CGRect, curve: UIView.AnimationCurve, duration: Double)

extension UIViewController {
    func keyboardNotificationHandler(_ notification: Notification) -> KeyboardPopInfo? {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let keyboardAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
              let keyboardDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let keyboardCurve = UIView.AnimationCurve(rawValue: keyboardAnimationCurve)
        else {
            return nil
        }
        return KeyboardPopInfo(frame: keyboardFrame, curve: keyboardCurve, duration: keyboardDuration)
    }
}
