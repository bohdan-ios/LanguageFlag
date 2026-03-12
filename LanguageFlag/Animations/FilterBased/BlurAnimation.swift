import Cocoa

/// Blur animation using Gaussian blur filter
class BlurAnimation: BaseWindowAnimation, WindowAnimation {

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

        let blurFilter = FilterBuilder.gaussianBlur(radius: 0.0)
        applyFilters([blurFilter], to: layer)
        
        let blurAnim = createAnimation(
            keyPath: "filters.CIGaussianBlur.inputRadius",
            from: 20.0,
            to: 0.0,
            duration: duration
        )
        blurAnim.fillMode = .forwards
        blurAnim.isRemovedOnCompletion = false
        blurAnim.delegate = AnimationCompletionDelegate { [weak self] finished in
            guard let self, finished else { return }
            self.clearFilters(from: layer)
            completion?()
        }

        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeOut)
        layer.add(blurAnim, forKey: "blur")
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
        
        let blurFilter = FilterBuilder.gaussianBlur(radius: 20.0)
        applyFilters([blurFilter], to: layer)
        
        let blurAnim = createAnimation(
            keyPath: "filters.CIGaussianBlur.inputRadius",
            from: 0.0,
            to: 20.0,
            duration: duration,
            timing: AnimationTiming.easeIn
        )
        blurAnim.fillMode = .forwards
        blurAnim.isRemovedOnCompletion = false
        blurAnim.delegate = AnimationCompletionDelegate { [weak self] finished in
            guard let self, finished else { return }
            self.clearFilters(from: layer)
            completion?()
        }

        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeIn)
        layer.add(blurAnim, forKey: "blur")
        CATransaction.commit()
        
        animateAlpha(
            contentView: contentView,
            from: 1.0,
            to: 0.0,
            duration: duration,
            timing: AnimationTiming.easeIn
        )
    }
}
