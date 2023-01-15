//
//  UIAlertController+Extension.swift
//  VoiceBulbTutor
//
//  Created by Konstantin Bezzemelnyi on 14.01.2023.
//

import UIKit


extension UIAlertController {

  func setContentViewController(_ controller: UIViewController, width: CGFloat? = nil, height: CGFloat? = nil) {
    setValue(controller, forKey: "contentViewController")
    if let height = height {
      controller.preferredContentSize.height = height
      preferredContentSize.height = height
    }
  }
  
  func setTitle(_ title: String, font: UIFont, color: UIColor) {
    self.title = title
    let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
    let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
    setValue(attributedTitle, forKey: "attributedTitle")
  }


  func addAction(
    image: UIImage? = nil,
    title: String,
    color: UIColor? = nil,
    style: UIAlertAction.Style = .default,
    isEnabled: Bool = true,
    handler: ((UIAlertAction) -> Void)? = nil
  ) {
    let action = UIAlertAction(title: title, style: style, handler: handler)
    action.isEnabled = isEnabled

    if let image = image {
      action.setValue(image, forKey: "image")
    }

    if let color = color {
      action.setValue(color, forKey: "titleTextColor")
    }

    addAction(action)
  }
}
