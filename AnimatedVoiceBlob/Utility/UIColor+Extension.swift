//
//  UIColor+Extension.swift
//  VoiceBulbTutor
//
//  Created by Konstantin Bezzemelnyi on 14.01.2023.
//

import UIKit

public extension UIColor {
  internal convenience init(hex: Int, alpha: CGFloat = 1.0) {
    let r = CGFloat((hex & 0xFF0000) >> 16)/255
    let g = CGFloat((hex & 0xFF00) >> 8)/255
    let b = CGFloat(hex & 0xFF)/255
    self.init(red: r, green: g, blue: b, alpha: alpha)
  }

  var hsbaComponents: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
    var hue: CGFloat = 0.0
    var saturation: CGFloat = 0.0
    var brightness: CGFloat = 0.0
    var alpha: CGFloat = 0.0

    self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    return (hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
  }

  var hexString: String {
    let components: [Int] = {
      let c = cgColor.components!
      let components = c.count == 4 ? c : [c[0], c[0], c[0], c[1]]
      return components.map { Int($0 * 255.0) }
    }()
    return String(format: "#%02X%02X%02X", components[0], components[1], components[2])
  }

  var shortHexString: String? {
    let string = hexString.replacingOccurrences(of: "#", with: "")
    let chrs = Array(string)
    guard chrs[0] == chrs[1], chrs[2] == chrs[3], chrs[4] == chrs[5] else { return nil }
    return "#\(chrs[0])\(chrs[2])\(chrs[4])"
  }
}
