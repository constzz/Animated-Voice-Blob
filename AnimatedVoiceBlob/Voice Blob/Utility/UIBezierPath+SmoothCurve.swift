//
//  UIBezierPath+SmoothCurve.swift
//  VoiceBulbTutor
//
//  Created by Konstantin Bezzemelnyi on 05.01.2023.
//

import UIKit

extension UIBezierPath {
  static func smoothCurve(
    through points: [CGPoint],
    length: CGFloat,
    smoothness: CGFloat
  ) -> UIBezierPath {
    var smoothPoints = [SmoothPoint]()
    for index in 0 ..< points.count {
      let prevIndex = index - 1
      let prev = points[prevIndex >= 0 ? prevIndex : points.count + prevIndex]
      let curr = points[index]
      let next = points[(index + 1) % points.count]

      let angle: CGFloat = {
        let dx = next.x - prev.x
        let dy = -next.y + prev.y
        let angle = atan2(dy, dx)
        if angle < 0 {
          return abs(angle)
        } else {
          return 2 * .pi - angle
        }
      }()

      smoothPoints.append(
        SmoothPoint(
          point: curr,
          inAngle: angle + .pi,
          inLength: smoothness * distance(from: curr, to: prev),
          outAngle: angle,
          outLength: smoothness * distance(from: curr, to: next)
        )
      )
    }

    let resultPath = UIBezierPath()
    resultPath.move(to: smoothPoints[0].point)
    for index in 0 ..< smoothPoints.count {
      let curr = smoothPoints[index]
      let next = smoothPoints[(index + 1) % points.count]
      let currSmoothOut = curr.smoothOut()
      let nextSmoothIn = next.smoothIn()
      resultPath.addCurve(to: next.point, controlPoint1: currSmoothOut, controlPoint2: nextSmoothIn)
    }
    resultPath.close()
    return resultPath
  }

  private static func distance(from fromPoint: CGPoint, to toPoint: CGPoint) -> CGFloat {
    return sqrt((fromPoint.x - toPoint.x) * (fromPoint.x - toPoint.x) + (fromPoint.y - toPoint.y) * (fromPoint.y - toPoint.y))
  }
}

private extension UIBezierPath {
  struct SmoothPoint {
    let point: CGPoint

    let inAngle: CGFloat
    let inLength: CGFloat

    let outAngle: CGFloat
    let outLength: CGFloat

    func smoothIn() -> CGPoint {
      return smooth(angle: inAngle, length: inLength)
    }

    func smoothOut() -> CGPoint {
      return smooth(angle: outAngle, length: outLength)
    }

    private func smooth(angle: CGFloat, length: CGFloat) -> CGPoint {
      return CGPoint(
        x: point.x + length * cos(angle),
        y: point.y + length * sin(angle)
      )
    }
  }
}
