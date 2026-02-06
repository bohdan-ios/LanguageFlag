import Cocoa

/// Ink Diffusion animation using Morphology and Blur
class InkDiffusionAnimation: BaseWindowAnimation, WindowAnimation {
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        guard
            let layer = prepareLayer(from: window),
            let contentView = window.contentView
        else {
            completion?()
            return
        }

        // Legacy: Morphology 10.0, Blur 15.0, Contrast 1.5
        let morphFilter = FilterBuilder.morphologyMaximum(radius: 10.0)
        let blurFilter = FilterBuilder.gaussianBlur(radius: 15.0)
        let colorFilter = FilterBuilder.colorControls(contrast: 1.5)
        
        applyFilters([morphFilter, blurFilter, colorFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeOut)
        CATransaction.setCompletionBlock {
            self.clearFilters(from: layer)
            completion?()
        }
        
        let morphAnim = createAnimation(keyPath: "filters.CIMorphologyMaximum.inputRadius", from: 10.0, to: 0.0, duration: duration)
        morphAnim.fillMode = .forwards
        morphAnim.isRemovedOnCompletion = false
        layer.add(morphAnim, forKey: "morph")
        
        let blurAnim = createAnimation(keyPath: "filters.CIGaussianBlur.inputRadius", from: 15.0, to: 0.0, duration: duration)
        blurAnim.fillMode = .forwards
        blurAnim.isRemovedOnCompletion = false
        layer.add(blurAnim, forKey: "blur")
        
        // Legacy: Animate contrast 1.5 -> 1.0
        let contrastAnim = createAnimation(keyPath: "filters.CIColorControls.inputContrast", from: 1.5, to: 1.0, duration: duration)
        contrastAnim.fillMode = .forwards
        contrastAnim.isRemovedOnCompletion = false
        layer.add(contrastAnim, forKey: "contrast")
        
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

        // Start: Normal (Contrast 1.0, Morph 0, Blur 0)
        let morphFilter = FilterBuilder.morphologyMaximum(radius: 0.0)
        let blurFilter = FilterBuilder.gaussianBlur(radius: 0.0)
        let colorFilter = FilterBuilder.colorControls(contrast: 1.0)
        
        applyFilters([morphFilter, blurFilter, colorFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeIn)
        CATransaction.setCompletionBlock {
            self.clearFilters(from: layer)
            completion?()
        }
        
        let morphAnim = createAnimation(keyPath: "filters.CIMorphologyMaximum.inputRadius", from: 0.0, to: 10.0, duration: duration)
        morphAnim.fillMode = .forwards
        morphAnim.isRemovedOnCompletion = false
        layer.add(morphAnim, forKey: "morph")
        
        let blurAnim = createAnimation(keyPath: "filters.CIGaussianBlur.inputRadius", from: 0.0, to: 15.0, duration: duration)
        blurAnim.fillMode = .forwards
        blurAnim.isRemovedOnCompletion = false
        layer.add(blurAnim, forKey: "blur")
        
        // Legacy: Animate contrast 1.0 -> 1.5
        let contrastAnim = createAnimation(keyPath: "filters.CIColorControls.inputContrast", from: 1.0, to: 1.5, duration: duration)
        contrastAnim.fillMode = .forwards
        contrastAnim.isRemovedOnCompletion = false
        layer.add(contrastAnim, forKey: "contrast")
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
    }
}
