//
//  CustomColorSetterView.swift
//  VoiceBulbTutor
//
//  Created by Konstantin Bezzemelnyi on 14.01.2023.
//

import UIKit
import AnimatedBlob

protocol CustomColorSetterView: UIView {
  func setNewCustomColor(_ color: UIColor?)
}

// MARK: - Implementations

extension VoiceBlobView: CustomColorSetterView {
  func setNewCustomColor(_ color: UIColor?) {
    setColor(color ?? .clear, animated: true)
  }
}
