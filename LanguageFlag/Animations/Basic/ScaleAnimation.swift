import Cocoa

/// Scale animation - window scales from small to normal or normal to small
class ScaleAnimation: BaseWindowAnimation, WindowAnimation {

    // MARK: - WindowAnimation
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        guard let layer = prepareLayer(from: window) else {
            completion?()
            return
        }
        setupWindow(window)

        // Hide window initially so we can fade it in
        window.alphaValue = 0

        let oldAnchor = layer.anchorPoint
        let oldPosition = layer.position

        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)

        let scaleAnim = createAnimation(keyPath: "transform.scale",
                                        from: 0.3,
                                        to: 1.0,
                                        duration: duration)
        scaleAnim.fillMode = .forwards
        scaleAnim.isRemovedOnCompletion = false

        scaleAnim.delegate = AnimationCompletionDelegate { [weak layer] _ in
            layer?.transform = CATransform3DIdentity
            layer?.anchorPoint = oldAnchor
            layer?.position = oldPosition
            completion?()
        }

        layer.add(scaleAnim, forKey: "scaleIn")

        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = AnimationTiming.easeOut
            window.animator().alphaValue = CGFloat(UserPreferences.shared.opacity)
        }
    }

    func animateOut(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        guard let layer = window.contentView?.layer else {
            completion?()
            return
        }

        let oldAnchor = layer.anchorPoint
        let oldPosition = layer.position

        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)

        let scaleAnim = createAnimation(keyPath: "transform.scale",
                                        from: 1.0,
                                        to: 0.3,
                                        duration: duration,
                                        timing: CAMediaTimingFunction(name: .easeIn))
        scaleAnim.fillMode = .forwards
        scaleAnim.isRemovedOnCompletion = false

        scaleAnim.delegate = AnimationCompletionDelegate { [weak layer] _ in
            layer?.transform = CATransform3DIdentity
            layer?.anchorPoint = oldAnchor
            layer?.position = oldPosition
            completion?()
        }

        layer.add(scaleAnim, forKey: "scaleOut")

        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = AnimationTiming.easeIn
            window.animator().alphaValue = 0
        }
    }
}
