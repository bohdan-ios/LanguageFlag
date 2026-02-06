import Cocoa

/// Flip animation - 3D flip effect on X axis
class FlipAnimation: BaseWindowAnimation, WindowAnimation {
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        guard
            let layer = prepareLayer(from: window),
            let contentView = window.contentView
        else {
            completion?()
            return
        }

        let originalFrame = layer.frame
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0) // Top center for "flipping down"
        layer.frame = originalFrame
        
        var startTransform = CATransform3DIdentity
        startTransform.m34 = -1.0 / 500.0 // Perspective
        startTransform = CATransform3DRotate(startTransform, -.pi / 2, 1, 0, 0)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeOut)
        CATransaction.setCompletionBlock {
            layer.transform = CATransform3DIdentity
            layer.anchorPoint = CGPoint(x: 0, y: 0)
            layer.frame = originalFrame
            completion?()
        }
        
        let flipAnim = createAnimation(keyPath: "transform", from: startTransform, to: CATransform3DIdentity, duration: duration)
        layer.add(flipAnim, forKey: "flip")
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 0.0, to: 1.0, duration: duration)
    }
    
    func animateOut(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        guard
            let layer = prepareLayer(from: window),
            let contentView = window.contentView
        else {
            completion?()
            return
        }

        let originalFrame = layer.frame
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        layer.frame = originalFrame
        
        var endTransform = CATransform3DIdentity
        endTransform.m34 = -1.0 / 500.0
        endTransform = CATransform3DRotate(endTransform, -.pi / 2, 1, 0, 0)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeIn)
        CATransaction.setCompletionBlock {
            layer.transform = CATransform3DIdentity
            layer.anchorPoint = CGPoint(x: 0, y: 0)
            layer.frame = originalFrame
            completion?()
        }
        
        let flipAnim = createAnimation(keyPath: "transform", from: CATransform3DIdentity, to: endTransform, duration: duration)
        layer.add(flipAnim, forKey: "flip")
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
    }
}
