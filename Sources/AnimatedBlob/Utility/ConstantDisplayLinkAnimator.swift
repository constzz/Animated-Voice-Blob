import UIKit

final class DisplayLinkTarget: NSObject {
    private let f: () -> Void
    
    public init(_ f: @escaping () -> Void) {
        self.f = f
    }
    
    @objc public func event() {
        self.f()
    }
}

final class ConstantDisplayLinkAnimator {
    private var displayLink: CADisplayLink?
    private let update: () -> Void
    private var completed = false
    
    public var frameInterval: Int = 1 {
        didSet {
            self.updateDisplayLink()
        }
    }
    
    private func updateDisplayLink() {
        guard let displayLink = self.displayLink else {
            return
        }
        if self.frameInterval == 1 {
            if #available(iOS 15.0, *) {
                self.displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60.0, maximum: 120.0, preferred: 120.0)
            }
        } else {
            displayLink.preferredFramesPerSecond = 30
        }
    }
    
    public var isPaused: Bool = true {
        didSet {
            if self.isPaused != oldValue {
                if !self.isPaused, self.displayLink == nil {
                    let displayLink = CADisplayLink(target: DisplayLinkTarget { [weak self] in
                        self?.tick()
                    }, selector: #selector(DisplayLinkTarget.event))
                    displayLink.add(to: RunLoop.main, forMode: .common)
                    self.displayLink = displayLink
                    self.updateDisplayLink()
                }
                
                self.displayLink?.isPaused = self.isPaused
            }
        }
    }
    
    public init(update: @escaping () -> Void) {
        self.update = update
    }
    
    deinit {
        if let displayLink = self.displayLink {
            displayLink.isPaused = true
            displayLink.invalidate()
        }
    }
    
    public func invalidate() {
        if let displayLink = self.displayLink {
            displayLink.isPaused = true
            displayLink.invalidate()
        }
    }
    
    @objc private func tick() {
        if self.completed {
            return
        }
        self.update()
    }
}
