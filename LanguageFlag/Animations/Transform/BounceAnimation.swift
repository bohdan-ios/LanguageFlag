import Cocoa

/// Bounce animation using Keyframe Animation
class BounceAnimation: BaseWindowAnimation, WindowAnimation {
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        guard let layer = prepareLayer(from: window),
              let contentView = window.contentView else {
            completion?()
            return
        }
        
        let originalFrame = layer.frame
        let centerX = originalFrame.midX
        let centerY = originalFrame.midY
        
        // Start Small
        let startScale: CGFloat = 0.3
        var startFrame = originalFrame
        startFrame.size.width *= startScale
        startFrame.size.height *= startScale
        startFrame.origin.x = centerX - startFrame.width / 2
        startFrame.origin.y = centerY - startFrame.height / 2
        
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
        
        layer.add(animation, forKey: "bounce")
        
        animateAlpha(contentView: contentView, from: 0.0, to: 1.0, duration: duration * 0.5)
        
        // Add completion delay to match duration
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
        animation.values = [1.0, 1.1, 0.3]
        animation.keyTimes = [0.0, 0.3, 1.0]
        animation.timingFunctions = [
            AnimationTiming.easeInOut,
            AnimationTiming.easeIn
        ]
        
        layer.add(animation, forKey: "bounce")
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion?()
        }
    }
}
