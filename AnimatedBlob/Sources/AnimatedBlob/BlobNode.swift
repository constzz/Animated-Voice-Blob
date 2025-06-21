import UIKit

@MainActor
final class BlobNode: UIView, BlobNodeProtocol, @preconcurrency CAAnimationDelegate {
    var pointsCount: Int {
        didSet {
            self.smoothness = Self.smoothnessForPointsCount(pointsCount: self.pointsCount)
        }
    }
    
    private var smoothness: CGFloat = .zero
    
    private let minRandomness: CGFloat
    private let maxRandomness: CGFloat
    
    private let minSpeed: CGFloat
    private let maxSpeed: CGFloat
    
    private let minScale: CGFloat
    private let maxScale: CGFloat
    private let scaleSpeed: CGFloat
    
    var isCircle: Bool {
        didSet { setNeedsDisplay() }
    }
    
    var color: UIColor? {
        if let color = shapeLayer.fillColor {
            return UIColor(cgColor: color)
        }
        
        return nil
    }
    
    var level: CGFloat = 0 {
        didSet {
            if abs(self.level - oldValue) > 0.01 {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                let lv = self.minScale + (self.maxScale - self.minScale) * self.level
                self.shapeLayer.transform = CATransform3DMakeScale(lv, lv, 1)
                CATransaction.commit()
            }
        }
    }
    
    private var speedLevel: CGFloat = 0
    private var scaleLevel: CGFloat = 0
    
    private var lastSpeedLevel: CGFloat = 0
    private var lastScaleLevel: CGFloat = 0
    
    private let shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = nil
        return layer
    }()
    
    private var transition: CGFloat = 0 {
        didSet {
            guard let currentPoints = currentPoints else { return }
            
            self.shapeLayer.path = UIBezierPath.smoothCurve(through: currentPoints, length: bounds.width, smoothness: self.smoothness).cgPath
        }
    }
    
    private var fromPoints: [CGPoint]?
    private var toPoints: [CGPoint]?
    
    private var currentPoints: [CGPoint]? {
        guard let fromPoints = fromPoints, let toPoints = toPoints else { return nil }
        
        return fromPoints.enumerated().map { offset, fromPoint in
            let toPoint = toPoints[offset]
            return CGPoint(
                x: fromPoint.x + (toPoint.x - fromPoint.x) * transition,
                y: fromPoint.y + (toPoint.y - fromPoint.y) * transition
            )
        }
    }
    
    init(
        pointsCount: Int,
        minRandomness: CGFloat,
        maxRandomness: CGFloat,
        minSpeed: CGFloat,
        maxSpeed: CGFloat,
        minScale: CGFloat,
        maxScale: CGFloat,
        scaleSpeed: CGFloat,
        isCircle: Bool
    ) {
        self.pointsCount = pointsCount
        self.minRandomness = minRandomness
        self.maxRandomness = maxRandomness
        self.minSpeed = minSpeed
        self.maxSpeed = maxSpeed
        self.minScale = minScale
        self.maxScale = maxScale
        self.scaleSpeed = scaleSpeed
        self.isCircle = isCircle
        
        self.smoothness = Self.smoothnessForPointsCount(pointsCount: pointsCount)
        
        super.init(frame: .zero)
        
        self.layer.addSublayer(self.shapeLayer)
        
        self.shapeLayer.transform = CATransform3DMakeScale(minScale, minScale, 1)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(_ color: UIColor, animated: Bool) {
        self.shapeLayer.fillColor = color.cgColor
    }
    
    func updateSpeedLevel(to newSpeedLevel: CGFloat) {
        self.speedLevel = max(self.speedLevel, newSpeedLevel)
    }
    
    func startAnimating() {
        self.animateToNewShape()
    }
    
    func stopAnimating() {
        self.shapeLayer.removeAnimation(forKey: "path")
    }
    
    private func animateToNewShape() {
        if self.isCircle { return }
        
        if self.shapeLayer.path == nil {
            let points = self.nextBlob(for: self.bounds.size)
            self.shapeLayer.path = UIBezierPath.smoothCurve(through: points, length: bounds.width, smoothness: self.smoothness).cgPath
        }
        
        let nextPoints = self.nextBlob(for: self.bounds.size)
        let nextPath = UIBezierPath.smoothCurve(through: nextPoints, length: bounds.width, smoothness: self.smoothness).cgPath
        
        let animation = CABasicAnimation(keyPath: "path")
        let previousPath = self.shapeLayer.path
        self.shapeLayer.path = nextPath
        animation.duration = CFTimeInterval(1 / (self.minSpeed + (self.maxSpeed - self.minSpeed) * self.speedLevel))
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fromValue = previousPath
        animation.toValue = nextPath
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.delegate = self
        
        self.shapeLayer.add(animation, forKey: "path")
        
        self.lastSpeedLevel = self.speedLevel
        self.speedLevel = 0
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.animateToNewShape()
        }
    }
    
    private func nextBlob(for size: CGSize) -> [CGPoint] {
        let randomness = self.minRandomness + (self.maxRandomness - self.minRandomness) * self.speedLevel
        return Self.blob(pointsCount: self.pointsCount, randomness: randomness)
            .map {
                return CGPoint(
                    x: $0.x * CGFloat(size.width),
                    y: $0.y * CGFloat(size.height)
                )
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        if self.isCircle {
            let halfWidth = self.bounds.width * 0.5
            self.shapeLayer.path = UIBezierPath(
                roundedRect: self.bounds.offsetBy(dx: -halfWidth, dy: -halfWidth),
                cornerRadius: halfWidth
            ).cgPath
        }
        CATransaction.commit()
    }
}

private extension BlobNode {
    static func blob(pointsCount: Int, randomness: CGFloat) -> [CGPoint] {
        let angle = (CGFloat.pi * 2) / CGFloat(pointsCount)
        
        let rgen = { () -> CGFloat in
            let accuracy: UInt32 = 1000
            let random = arc4random_uniform(accuracy)
            return CGFloat(random) / CGFloat(accuracy)
        }
        
        let rangeStart: CGFloat = 1 / (1 + randomness / 10)
        
        let startAngle = angle * CGFloat(arc4random_uniform(100)) / CGFloat(100)
        
        let points = (0 ..< pointsCount).map { i -> CGPoint in
            let randPointOffset = (rangeStart + CGFloat(rgen()) * (1 - rangeStart)) / 2
            let angleRandomness: CGFloat = angle * 0.1
            let randAngle = angle + angle * ((angleRandomness * CGFloat(arc4random_uniform(100)) / CGFloat(100)) - angleRandomness * 0.5)
            let pointX = sin(startAngle + CGFloat(i) * randAngle)
            let pointY = cos(startAngle + CGFloat(i) * randAngle)
            return CGPoint(
                x: pointX * randPointOffset,
                y: pointY * randPointOffset
            )
        }
        
        return points
    }
    
    private static func smoothnessForPointsCount(pointsCount: Int) -> CGFloat {
        let angle = (CGFloat.pi * 2) / CGFloat(pointsCount)
        return ((4 / 3) * tan(angle / 4)) / sin(angle / 2) / 2
    }
}
