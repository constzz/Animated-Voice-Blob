//
//  GradientSlider.swift
//  AnimatedVoiceBlob
//
//  Created by Konstantin Bezzemelnyi on 15.01.2023.
//

import UIKit

final class GradientSlider: UIControl {
  private enum Constants {
    static let defaultThickness: CGFloat = 2.0
    static let defaultThumbSize: CGFloat = 28.0
  }

  /// Uses saturation & lightness from minColor/
  var hasRainbow: Bool = false { didSet { updateTrackColors() }}
  var minColor: UIColor = .black { didSet { updateTrackColors() }}
  var maxColor: UIColor = .black { didSet { updateTrackColors() }}

  var value: CGFloat {
    get { return _value }
    set { set(value: newValue, animated: true) }
  }

  /// The current value may change if outside new min value
  var minimumValue: CGFloat = 0.0

  /// The current value may change if outside new max value
  var maximumValue: CGFloat = 1.0

  var valueChangedAction: (GradientSlider, CGFloat) -> () = { _, _ in }

  var thickness: CGFloat = Constants.defaultThickness {
    didSet {
      trackLayer.cornerRadius = thickness/2.0
      self.layer.setNeedsLayout()
    }
  }

  var trackBorderColor: UIColor? {
    set { trackLayer.borderColor = newValue?.cgColor }
    get {
      if let color = trackLayer.borderColor {
        return UIColor(cgColor: color)
      } else { return nil }
    }
  }

  var trackBorderWidth: CGFloat {
    set { trackLayer.borderWidth = newValue }
    get { return trackLayer.borderWidth }
  }

  var thumbSize: CGFloat = Constants.defaultThumbSize {
    didSet {
      thumbLayer.cornerRadius = thumbSize/2.0
      thumbLayer.bounds = CGRect(x: 0, y: 0, width: thumbSize, height: thumbSize)
      self.invalidateIntrinsicContentSize()
    }
  }

  /// This value will be pinned to min/max
  private var _value: CGFloat = 0.0

  private lazy var thumbLayer: CALayer = makeThumbLayer()

  private lazy var trackLayer: CAGradientLayer = makeTrackLayer()

  private lazy var thumbIconLayer: CALayer = makeThumbIconLayer()

  func set(value: CGFloat, animated: Bool = true) {
    _value = max(min(value, self.maximumValue), self.minimumValue)
    updateThumbPosition(animated: animated)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonSetup()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func commonSetup() {
    self.layer.delegate = self
    self.layer.addSublayer(trackLayer)
    self.layer.addSublayer(thumbLayer)
    thumbLayer.addSublayer(thumbIconLayer)
  }
}

extension GradientSlider {
  override public var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: thumbSize)
  }

  override public var alignmentRectInsets: UIEdgeInsets {
    UIEdgeInsets(top: 4.0, left: 2.0, bottom: 4.0, right: 2.0)
  }

  override public func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)

    if layer != self.layer { return }

    var width = self.bounds.width
    let height = self.bounds.height
    let left: CGFloat = 2.0

    width -= left
    width -= 2.0

    trackLayer.bounds = CGRect(x: 0, y: 0, width: width, height: thickness)
    trackLayer.position = CGPoint(x: width/2.0 + left, y: height/2.0)

    let halfSize = thumbSize/2.0
    let layerSize = thumbSize - 4.0
    thumbIconLayer.cornerRadius = layerSize/2.0
    thumbIconLayer.position = CGPoint(x: halfSize, y: halfSize)
    thumbIconLayer.bounds = CGRect(x: 0, y: 0, width: layerSize, height: layerSize)

    updateThumbPosition(animated: false)
  }
}

// MARK: - Touch tracking

extension GradientSlider {
  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let point = touch.location(in: self)

    let center = thumbLayer.position
    let diameter = max(thumbSize, 44.0)
    let radius = CGRect(x: center.x - diameter/2.0, y: center.y - diameter/2.0, width: diameter, height: diameter)
    if radius.contains(point) {
      sendActions(for: .touchDown)
      return true
    }
    return false
  }

  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    if let pt = touch?.location(in: self) {
      let newValue = valueForLocation(point: pt)
      set(value: newValue, animated: false)
    }
    valueChangedAction(self, _value)
    sendActions(for: [UIControl.Event.valueChanged, UIControl.Event.touchUpInside])
  }

  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let point = touch.location(in: self)
    let newValue = valueForLocation(point: point)
    set(value: newValue, animated: false)
    return true
  }
}

private extension GradientSlider {
  func makeThumbLayer() -> CALayer {
    let thumb = CALayer()
    thumb.cornerRadius = Constants.defaultThumbSize/2.0
    thumb.bounds = CGRect(x: 0, y: 0, width: Constants.defaultThumbSize, height: Constants.defaultThumbSize)
    thumb.backgroundColor = UIColor.white.cgColor
    thumb.shadowColor = UIColor.black.cgColor
    thumb.shadowOffset = CGSize(width: 0.0, height: 2.5)
    thumb.shadowRadius = 2.0
    thumb.shadowOpacity = 0.25
    thumb.borderColor = UIColor.black.withAlphaComponent(0.15).cgColor
    thumb.borderWidth = 0.5
    return thumb
  }

  func makeThumbIconLayer() -> CALayer {
    let size = Constants.defaultThumbSize - 4
    let iconLayer = CALayer()
    iconLayer.cornerRadius = size/2.0
    iconLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
    iconLayer.backgroundColor = UIColor.white.cgColor
    return iconLayer
  }

  func makeTrackLayer() -> CAGradientLayer {
    let track = CAGradientLayer()
    track.cornerRadius = Constants.defaultThickness/2.0
    track.startPoint = CGPoint(x: 0.0, y: 0.5)
    track.endPoint = CGPoint(x: 1.0, y: 0.5)
    track.locations = [0.0, 1.0]
    track.colors = [UIColor.blue.cgColor, UIColor.orange.cgColor]
    track.borderColor = UIColor.black.cgColor
    return track
  }
}

private extension GradientSlider {
  func valueForLocation(point: CGPoint) -> CGFloat {
    var left = self.bounds.origin.x
    var w = self.bounds.width
    w -= 2.0
    left += 2.0

    w -= 2.0

    let diff = CGFloat(self.maximumValue - self.minimumValue)

    let perc = max(min((point.x - left)/w, 1.0), 0.0)

    return (perc * diff) + CGFloat(self.minimumValue)
  }

  func updateTrackColors() {
    guard hasRainbow else {
      trackLayer.colors = [minColor.cgColor, maxColor.cgColor]
      trackLayer.locations = [0.0, 1.0]
      return
    }

    // Otherwise make a rainbow with the saturation & lightness of the min color
    var hue: CGFloat = 0.0
    var saturation: CGFloat = 0.0
    var brightness: CGFloat = 0.0
    var alpha: CGFloat = 1.0

    minColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

    let cnt = 40
    let step: CGFloat = 1.0/CGFloat(cnt)
    let locations: [CGFloat] = (0 ... cnt).map { i in step * CGFloat(i) }
    trackLayer.colors = locations.map { UIColor(hue: $0, saturation: saturation, brightness: brightness, alpha: alpha).cgColor }
    trackLayer.locations = locations as [NSNumber]
  }

  func updateThumbPosition(animated: Bool) {
    let diff = maximumValue - minimumValue
    let perc = CGFloat((value - minimumValue)/diff)

    let halfHeight = self.bounds.height/2.0
    let trackWidth = trackLayer.bounds.width - thumbSize
    let left = trackLayer.position.x - trackWidth/2.0

    if !animated {
      CATransaction.begin() // Move the thumb position without animations
      CATransaction.setValue(true, forKey: kCATransactionDisableActions)
      thumbLayer.position = CGPoint(x: left + (trackWidth * perc), y: halfHeight)
      CATransaction.commit()
    } else {
      thumbLayer.position = CGPoint(x: left + (trackWidth * perc), y: halfHeight)
    }
  }
}
