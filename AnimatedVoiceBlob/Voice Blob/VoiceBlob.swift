//
//  VoiceBlob.swift
//  VoiceBulbTutor
//
//  Created by Konstantin Bezzemelnyi on 05.01.2023.
//

import UIKit

public final class VoiceBlobView: UIView {
  private(set) var smallBlob: BlobNode
  private(set) var mediumBlob: BlobNode
  private(set) var bigBlob: BlobNode

  private let maxLevel: CGFloat

  private var displayLinkAnimator: ConstantDisplayLinkAnimator?

  private var audioLevel: CGFloat = 0
  public var presentationAudioLevel: CGFloat = 0

  private(set) var isAnimating = false

  public typealias BlobRange = (min: CGFloat, max: CGFloat)

  public init(
    frame: CGRect,
    maxLevel: CGFloat,
    smallBlobRange: BlobRange,
    mediumBlobRange: BlobRange,
    bigBlobRange: BlobRange
  ) {
    self.maxLevel = maxLevel

    self.smallBlob = BlobNode(
      pointsCount: 8,
      minRandomness: 0.1,
      maxRandomness: 0.5,
      minSpeed: 0.2,
      maxSpeed: 0.6,
      minScale: smallBlobRange.min,
      maxScale: smallBlobRange.max,
      scaleSpeed: 0.2,
      isCircle: true
    )
    self.mediumBlob = BlobNode(
      pointsCount: 8,
      minRandomness: 1,
      maxRandomness: 1,
      minSpeed: 0.9,
      maxSpeed: 4,
      minScale: mediumBlobRange.min,
      maxScale: mediumBlobRange.max,
      scaleSpeed: 0.2,
      isCircle: false
    )
    self.bigBlob = BlobNode(
      pointsCount: 8,
      minRandomness: 1,
      maxRandomness: 1,
      minSpeed: 0.9,
      maxSpeed: 4,
      minScale: bigBlobRange.min,
      maxScale: bigBlobRange.max,
      scaleSpeed: 0.2,
      isCircle: false
    )

    super.init(frame: .zero)

    addSubview(bigBlob)
    addSubview(mediumBlob)
    addSubview(smallBlob)

    self.displayLinkAnimator = ConstantDisplayLinkAnimator { [weak self] in
      guard let self = self else { return }

      self.presentationAudioLevel = self.presentationAudioLevel * 0.9 + self.audioLevel * 0.1

      self.smallBlob.level = self.presentationAudioLevel
      self.mediumBlob.level = self.presentationAudioLevel
      self.bigBlob.level = self.presentationAudioLevel
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func setColor(_ color: UIColor) {
    setColor(color, animated: false)
  }

  public func setColor(_ color: UIColor, animated: Bool) {
    smallBlob.setColor(color, animated: animated)
    mediumBlob.setColor(color.withAlphaComponent(0.3), animated: animated)
    bigBlob.setColor(color.withAlphaComponent(0.15), animated: animated)
  }

  public func updateLevel(_ level: CGFloat) {
    updateLevel(level, immediately: false)
  }

  public func updateLevel(_ level: CGFloat, immediately: Bool = false) {
    let normalizedLevel = min(1, max(level / maxLevel, 0))

    smallBlob.updateSpeedLevel(to: normalizedLevel)
    mediumBlob.updateSpeedLevel(to: normalizedLevel)
    bigBlob.updateSpeedLevel(to: normalizedLevel)

    audioLevel = normalizedLevel
    if immediately {
      presentationAudioLevel = normalizedLevel
    }
  }

  public func startAnimating() {
    startAnimating(immediately: false)
  }

  public func startAnimating(immediately: Bool = false) {
    guard !isAnimating else { return }
    isAnimating = true

    if !immediately {
      mediumBlob.layer.animateScale(from: 0.75, to: 1, duration: 0.35, removeOnCompletion: false)
      bigBlob.layer.animateScale(from: 0.75, to: 1, duration: 0.35, removeOnCompletion: false)
    } else {
      mediumBlob.layer.removeAllAnimations()
      bigBlob.layer.removeAllAnimations()
    }

    updateBlobsState()

    displayLinkAnimator?.isPaused = false
  }

  public func stopAnimating() {
    stopAnimating(duration: 0.15)
  }

  public func stopAnimating(duration: Double) {
    guard isAnimating else { return }
    isAnimating = false

    mediumBlob.layer.animateScale(from: 1.0, to: 0.75, duration: duration, removeOnCompletion: false)
    bigBlob.layer.animateScale(from: 1.0, to: 0.75, duration: duration, removeOnCompletion: false)

    updateBlobsState()

    displayLinkAnimator?.isPaused = true
  }

  private func updateBlobsState() {
    if isAnimating {
      if smallBlob.frame.size != .zero {
        smallBlob.startAnimating()
        mediumBlob.startAnimating()
        bigBlob.startAnimating()
      }
    } else {
      smallBlob.stopAnimating()
      mediumBlob.stopAnimating()
      bigBlob.stopAnimating()
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    smallBlob.frame = bounds
    mediumBlob.frame = bounds
    bigBlob.frame = bounds

    updateBlobsState()
  }
}
