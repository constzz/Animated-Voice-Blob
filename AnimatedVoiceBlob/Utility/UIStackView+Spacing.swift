//
//  UIStackView+Spacing.swift
//  VoiceBulbTutor
//
//  Created by Konstantin Bezzemelnyi on 05.01.2023.
//

import UIKit

extension UIStackView {
  func addArrangedSubview(_ view: UIView, withSpacing spacing: CGFloat) {
    let view = view
    addArrangedSubview(view)
    setCustomSpacing(spacing, after: view)
  }

}

