//
//  UIView+Extensions.swift
//  VoiceBulbTutor
//
//  Created by Konstantin Bezzemelnyi on 05.01.2023.
//

import UIKit

extension UIView {
  func pinToSuperView(top: CGFloat? = 0, left: CGFloat? = 0, bottom: CGFloat? = 0, right: CGFloat? = 0) {
    guard let superview = self.superview else { return }
    prepareForAutoLayout()

    if let top = top {
      self.topAnchor.constraint(equalTo: superview.topAnchor, constant: top).isActive = true
    }

    if let bottom = bottom {
      self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom).isActive = true
    }

    if let left = left {
      self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: left).isActive = true
    }

    if let right = right {
      self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: right).isActive = true
    }
  }

  func pinTo(view: UIView, top: CGFloat? = 0, left: CGFloat? = 0, bottom: CGFloat? = 0, right: CGFloat? = 0) {
    guard let view = self.superview else { return }

    prepareForAutoLayout()

    if let top = top {
      self.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
    }

    if let bottom = bottom {
      self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom).isActive = true
    }

    if let left = left {
      self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: left).isActive = true
    }

    if let right = right {
      self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: right).isActive = true
    }
  }

  func constraint(width: CGFloat) {
    prepareForAutoLayout()
    self.widthAnchor.constraint(equalToConstant: width).isActive = true
  }

  func constraint(height: CGFloat) {
    prepareForAutoLayout()
    self.heightAnchor.constraint(equalToConstant: height).isActive = true
  }

  func makeWidthEqualHeight() {
    prepareForAutoLayout()
    self.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
  }

  func prepareForAutoLayout() {
    translatesAutoresizingMaskIntoConstraints = false
  }

  func add(views: [UIView], constraints: [NSLayoutConstraint]) {
    views.forEach {
      $0.prepareForAutoLayout()
      addSubview($0)
    }

    NSLayoutConstraint.activate(constraints)
  }

  func add(view: UIView, constraints: [NSLayoutConstraint]) {
    add(views: [view], constraints: constraints)
  }
}
