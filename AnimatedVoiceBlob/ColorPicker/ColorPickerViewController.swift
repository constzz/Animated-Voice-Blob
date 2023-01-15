//
//  ColorPickerViewController.swift
//  VoiceBulbTutor
//
//  Created by Konstantin Bezzemelnyi on 13.01.2023.
//

import Foundation
import UIKit

final class ColorPickerViewController: UIViewController {

  public typealias Selection = (UIColor) -> Swift.Void

  private var selection: Selection?

  var colorView: CustomColorSetterView? {
    didSet {
      guard let colorView = colorView else { return }
      colorView.prepareForAutoLayout()
      colorView.constraint(height: 200)
      view.constraint(width: 200)
      mainStackView.insertArrangedSubview(colorView, at: 0)
    }
  }

  private lazy var saturationSlider: GradientSlider = makeSaturationSlider()
  private lazy var brightnessSlider: GradientSlider = makeBrightnessSlider()
  private lazy var hueSlider: GradientSlider = makeHueSlider()

  private lazy var mainStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    return stackView
  }()

  public var color: UIColor {
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
  }

  public var hue: CGFloat = 0.5
  public var saturation: CGFloat = 0.5
  public var brightness: CGFloat = 0.5
  public var alpha: CGFloat = 1

  func setup(color: UIColor, selection: Selection?) {
    let components = color.hsbaComponents

    hue = components.hue
    saturation = components.saturation
    brightness = components.brightness
    alpha = components.alpha

    let mainColor: UIColor = UIColor(
      hue: hue,
      saturation: 1.0,
      brightness: 1.0,
      alpha: 1.0)

    hueSlider.minColor = mainColor
    brightnessSlider.maxColor = mainColor
    saturationSlider.maxColor = mainColor

    hueSlider.value = hue
    saturationSlider.value = saturation
    brightnessSlider.value = brightness

    updateColorView()

    self.selection = selection
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(mainStackView)
    mainStackView.pinToSuperView()
    mainStackView.addArrangedSubview(saturationSlider)
    mainStackView.addArrangedSubview(brightnessSlider)
    mainStackView.addArrangedSubview(hueSlider)
  }

  func updateColorView() {
    colorView?.setNewCustomColor(color)
    selection?(color)
  }
}

// MARK: - Sliders factories
private extension ColorPickerViewController {
  func makeHueSlider() -> GradientSlider {
    let slider = GradientSlider(frame: .zero)
    slider.hasRainbow = true

    slider.valueChangedAction = { [weak self] slider, newValue in
      guard let self = self else { return }
      CATransaction.begin()
      CATransaction.setValue(true, forKey: kCATransactionDisableActions)

      self.hue = newValue
      let mainColor: UIColor = UIColor(
        hue: newValue,
        saturation: 1.0,
        brightness: 1.0,
        alpha: 1.0)

      self.brightnessSlider.maxColor = mainColor
      self.saturationSlider.maxColor = mainColor

      self.updateColorView()

      CATransaction.commit()
    }
    return slider
  }

  func makeBrightnessSlider() -> GradientSlider {
    let slider = GradientSlider(frame: .zero)

    slider.minColor = .black

    slider.valueChangedAction = { [weak self] slider, newValue in
      guard let self = self else { return }
      CATransaction.begin()
      CATransaction.setValue(true, forKey: kCATransactionDisableActions)

      self.brightness = newValue
      self.updateColorView()

      CATransaction.commit()
    }
    return slider
  }

  func makeSaturationSlider() -> GradientSlider {
    let slider = GradientSlider(frame: .zero)
    slider.minColor = .white
    slider.valueChangedAction = { [weak self] slider, newValue in
      guard let self = self else { return }
      CATransaction.begin()
      CATransaction.setValue(true, forKey: kCATransactionDisableActions)

      self.saturation = newValue
      self.updateColorView()

      CATransaction.commit()
    }

    return slider
  }
}

