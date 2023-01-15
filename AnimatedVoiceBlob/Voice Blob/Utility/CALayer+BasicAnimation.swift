//
//  CALayer+BasicAnimation.swift
//  VoiceBulbTutor
//
//  Created by Konstantin Bezzemelnyi on 05.01.2023.
//

import UIKit

extension CALayer {
  @discardableResult
  func animateScale(from fromValue: CGFloat, to toValue: CGFloat, duration: Double, removeOnCompletion: Bool) -> CABasicAnimation {
    let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
    scaleAnimation.fromValue = fromValue
    scaleAnimation.toValue = toValue
    scaleAnimation.duration = duration
    scaleAnimation.repeatCount = .infinity
    scaleAnimation.isRemovedOnCompletion = removeOnCompletion
    scaleAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
    return scaleAnimation
  }
}
