//
//  UIAlertController+ColorPicker.swift
//  VoiceBulbTutor
//
//  Created by Konstantin Bezzemelnyi on 14.01.2023.
//

import UIKit

private enum Constants {
  static let titleFont = UIFont.systemFont(ofSize: 17)
}

extension UIAlertController {
  func addColorPicker(
    currentColor: UIColor = .clear,
    selection: @escaping ColorPickerViewController.Selection,
    colorView: CustomColorSetterView
  ) {
    let controller = ColorPickerViewController()
    controller.colorView = colorView
    setContentViewController(controller)

    setTitle(currentColor.hexString, font: Constants.titleFont, color: currentColor)

    controller.setup(color: currentColor) { [weak self] newColor in
      self?.setTitle(currentColor.hexString, font: Constants.titleFont, color: newColor)
      selection(controller.color)
    }

    let buttonSelection = UIAlertAction(title: "Select", style: .default)
    addAction(buttonSelection)
  }
}
