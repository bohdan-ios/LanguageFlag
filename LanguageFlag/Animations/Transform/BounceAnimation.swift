import Cocoa

/// Bounce animation using Keyframe Animation
class BounceAnimation: BaseWindowAnimation, WindowAnimation {

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
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.0) // Bottom middle
        layer.frame = originalFrame
        
        // Keyframe Animation
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.duration = duration
        animation.values = [0.3, 1.1, 0.9, 1.0]
        animation.keyTimes = [0.0, 0.4, 0.7, 1.0]
        animation.timingFunctions = [
            AnimationTiming.easeIn,
            AnimationTiming.easeInOut,
            AnimationTiming.easeInOut
        ]
        
        CATransaction.begin()
        
        animation.delegate = AnimationCompletionDelegate { finished in
            guard finished else { return }
            layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            layer.frame = originalFrame
            completion?()
        }
        
        layer.add(animation, forKey: "bounce")
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 0.0, to: 1.0, duration: duration * 0.5)
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
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.0) // Bottom middle
        layer.frame = originalFrame

        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.duration = duration
        animation.values = [1.0, 1.1, 0.3]
        animation.keyTimes = [0.0, 0.3, 1.0]
        animation.timingFunctions = [
            AnimationTiming.easeInOut,
            AnimationTiming.easeIn
        ]
        
        CATransaction.begin()
        
        animation.delegate = AnimationCompletionDelegate { finished in
            guard finished else { return }
            layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            layer.frame = originalFrame
            completion?()
        }
        
        layer.add(animation, forKey: "bounce")
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
    }
}
