import Cocoa

/// Rotate animation - rotates window 360 degrees
class RotateAnimation: BaseWindowAnimation, WindowAnimation {

    // MARK: - WindowAnimation
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
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.frame = originalFrame
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeOut)
        CATransaction.setCompletionBlock {
            layer.transform = CATransform3DIdentity
            layer.anchorPoint = CGPoint(x: 0, y: 0)
            layer.frame = originalFrame
            completion?()
        }
        
        let rotateAnim = createAnimation(keyPath: "transform.rotation.z", from: CGFloat.pi * 2, to: 0.0, duration: duration)
        layer.add(rotateAnim, forKey: "rotate")
        
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
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.frame = originalFrame
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeIn)
        CATransaction.setCompletionBlock {
            layer.transform = CATransform3DIdentity
            layer.anchorPoint = CGPoint(x: 0, y: 0)
            layer.frame = originalFrame
            completion?()
        }
        
        let rotateAnim = createAnimation(keyPath: "transform.rotation.z", from: 0.0, to: CGFloat.pi * 2, duration: duration)
        layer.add(rotateAnim, forKey: "rotate")
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
    }
}
