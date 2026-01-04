import Cocoa

/// Swing animation - Swings on X axis like a sign
class SwingAnimation: BaseWindowAnimation, WindowAnimation {
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        guard let layer = prepareLayer(from: window),
              let contentView = window.contentView else {
            completion?()
            return
        }
        
        let originalFrame = layer.frame
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        layer.frame = originalFrame
        
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.duration = duration
        
        // Create transform values for swinging
        let angles: [CGFloat] = [-.pi/2, .pi/4, -.pi/8, .pi/16, 0]
        animation.values = angles.map { angle -> CATransform3D in
            return CATransform3DRotate(transform, angle, 1, 0, 0)
        }
        
        animation.keyTimes = [0.0, 0.4, 0.6, 0.8, 1.0]
        animation.timingFunctions = [
            AnimationTiming.easeOut,
            AnimationTiming.easeInOut,
            AnimationTiming.easeInOut,
            AnimationTiming.easeInOut
        ]
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            layer.transform = CATransform3DIdentity
            layer.anchorPoint = CGPoint(x: 0, y: 0)
            layer.frame = originalFrame
            completion?()
        }
        
        layer.add(animation, forKey: "swing")
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 0.0, to: 1.0, duration: duration * 0.3)
    }
    
    func animateOut(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        guard let layer = prepareLayer(from: window),
              let contentView = window.contentView else {
            completion?()
            return
        }
        
        let originalFrame = layer.frame
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        layer.frame = originalFrame
        
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = CATransform3DIdentity
        animation.toValue = CATransform3DRotate(transform, -.pi/2, 1, 0, 0)
        animation.duration = duration
        animation.timingFunction = AnimationTiming.easeIn
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            layer.transform = CATransform3DIdentity
            layer.anchorPoint = CGPoint(x: 0, y: 0)
            layer.frame = originalFrame
            completion?()
        }
        
        layer.add(animation, forKey: "swing")
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
    }
}
