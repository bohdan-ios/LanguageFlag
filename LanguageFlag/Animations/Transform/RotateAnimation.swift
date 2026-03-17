import Cocoa

/// Rotate animation - rotates window 360 degrees
class RotateAnimation: BaseWindowAnimation, WindowAnimation {

    // MARK: - WindowAnimation
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        guard
            let layer = prepareLayer(from: window),
            let contentView = window.contentView
        else {
            completion?()
            return
        }
        setupWindow(window)

        let oldAnchor = layer.anchorPoint
        let oldPosition = layer.position

        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        
        // Calculate the mathematically perfect scale down to ensure the diagonal
        // never clips the shortest dimension of the window bounds during the spin.
        let width = layer.bounds.width
        let height = layer.bounds.height
        let diagonal = hypot(width, height)
        let minDimension = min(width, height)
        // Add a slight 2% margin of safety
        let safeScale = (minDimension / diagonal) * 0.98
        
        let rotateAnim = createAnimation(keyPath: "transform.rotation.z", from: CGFloat.pi * 2, to: 0.0, duration: duration)
        
        let scaleAnim = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnim.values = [1.0, safeScale, 1.0]
        scaleAnim.keyTimes = [0.0, 0.5, 1.0]
        scaleAnim.duration = duration
        scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        let group = CAAnimationGroup()
        group.animations = [rotateAnim, scaleAnim]
        group.duration = duration
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        
        group.delegate = AnimationCompletionDelegate { [weak layer] _ in
            layer?.transform = CATransform3DIdentity
            layer?.anchorPoint = oldAnchor
            layer?.position = oldPosition
            completion?()
        }
        
        layer.add(group, forKey: "rotateIn")
        
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

        let oldAnchor = layer.anchorPoint
        let oldPosition = layer.position

        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        
        let width = layer.bounds.width
        let height = layer.bounds.height
        let diagonal = hypot(width, height)
        let minDimension = min(width, height)
        let safeScale = (minDimension / diagonal) * 0.98
        
        let rotateAnim = createAnimation(keyPath: "transform.rotation.z", from: 0.0, to: CGFloat.pi * 2, duration: duration, timing: CAMediaTimingFunction(name: .easeIn))
        
        let scaleAnim = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnim.values = [1.0, safeScale, 1.0]
        scaleAnim.keyTimes = [0.0, 0.5, 1.0]
        scaleAnim.duration = duration
        scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeIn)
        
        let group = CAAnimationGroup()
        group.animations = [rotateAnim, scaleAnim]
        group.duration = duration
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        
        group.delegate = AnimationCompletionDelegate { [weak layer] _ in
            layer?.transform = CATransform3DIdentity
            layer?.anchorPoint = oldAnchor
            layer?.position = oldPosition
            completion?()
        }
        
        layer.add(group, forKey: "rotateOut")
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration, timing: CAMediaTimingFunction(name: .easeIn))
    }
}
