import Cocoa

/// Ink Diffusion animation using Morphology and Blur
class InkDiffusionAnimation: BaseWindowAnimation, WindowAnimation {

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

        // Legacy: Morphology 10.0, Blur 15.0
        let morphFilter = FilterBuilder.morphologyMaximum(radius: 10.0)
        let blurFilter = FilterBuilder.gaussianBlur(radius: 15.0)
        
        applyFilters([morphFilter, blurFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeOut)
        
        let morphAnim = createAnimation(keyPath: "filters.CIMorphologyMaximum.inputRadius", from: 10.0, to: 0.0, duration: duration)
        morphAnim.fillMode = .forwards
        morphAnim.isRemovedOnCompletion = false
        morphAnim.delegate = AnimationCompletionDelegate { finished in
            guard finished else { return }
            layer.filters = nil
            layer.removeAllAnimations()
            completion?()
        }
        layer.add(morphAnim, forKey: "morph")
        
        let blurAnim = createAnimation(keyPath: "filters.CIGaussianBlur.inputRadius", from: 15.0, to: 0.0, duration: duration)
        blurAnim.fillMode = .forwards
        blurAnim.isRemovedOnCompletion = false
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

        // Start: Normal (Morph 0, Blur 0)
        let morphFilter = FilterBuilder.morphologyMaximum(radius: 0.0)
        let blurFilter = FilterBuilder.gaussianBlur(radius: 0.0)
        
        applyFilters([morphFilter, blurFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeIn)
        
        let morphAnim = createAnimation(keyPath: "filters.CIMorphologyMaximum.inputRadius", from: 0.0, to: 10.0, duration: duration)
        morphAnim.fillMode = .forwards
        morphAnim.isRemovedOnCompletion = false
        morphAnim.delegate = AnimationCompletionDelegate { finished in
            guard finished else { return }
            layer.filters = nil
            layer.removeAllAnimations()
            completion?()
        }
        layer.add(morphAnim, forKey: "morph")
        
        let blurAnim = createAnimation(keyPath: "filters.CIGaussianBlur.inputRadius", from: 0.0, to: 15.0, duration: duration)
        blurAnim.fillMode = .forwards
        blurAnim.isRemovedOnCompletion = false
        layer.add(blurAnim, forKey: "blur")
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
    }
}
