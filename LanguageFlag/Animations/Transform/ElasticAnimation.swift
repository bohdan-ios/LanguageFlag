import Cocoa

/// Elastic animation - Overshoots and settles
class ElasticAnimation: BaseWindowAnimation, WindowAnimation {
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        guard let layer = prepareLayer(from: window),
              let contentView = window.contentView else {
            completion?()
            return
        }
        
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.duration = duration
        // Elastic overshoot values
        animation.values = [0.0, 1.25, 0.9, 1.05, 0.95, 1.0]
        animation.keyTimes = [0.0, 0.4, 0.6, 0.8, 0.9, 1.0]
        animation.timingFunctions = [
            AnimationTiming.easeOut,
            AnimationTiming.easeInOut,
            AnimationTiming.easeInOut,
            AnimationTiming.easeInOut,
            AnimationTiming.easeInOut
        ]
        
        layer.add(animation, forKey: "elastic")
        
        animateAlpha(contentView: contentView, from: 0.0, to: 1.0, duration: duration * 0.3)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion?()
        }
    }
    
    func animateOut(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        guard let layer = prepareLayer(from: window),
              let contentView = window.contentView else {
            completion?()
            return
        }
        
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.duration = duration
        animation.values = [1.0, 1.1, 0.0]
        animation.keyTimes = [0.0, 0.2, 1.0]
        animation.timingFunctions = [
            AnimationTiming.easeOut,
            AnimationTiming.easeIn
        ]
        
        layer.add(animation, forKey: "elastic")
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion?()
        }
    }
}
