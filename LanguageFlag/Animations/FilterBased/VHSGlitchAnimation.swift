import Cocoa

/// VHS Glitch animation using overlay layers, posterization, and motion blur
class VHSGlitchAnimation: BaseWindowAnimation, WindowAnimation {

    // Helper manager for overlays
    private let overlays = VHSOverlayManager()
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)

        guard
            let layer = prepareLayer(from: window),
            let contentView = window.contentView
        else {
            completion?()
            return
        }

        // Filters
        let blurFilter = FilterBuilder.gaussianBlur(radius: 3.0)
        let posterFilter = FilterBuilder.colorPosterize(levels: 8.0)
        let colorFilter = FilterBuilder.colorControls(saturation: 0.8)
        let motionFilter = FilterBuilder.motionBlur(radius: 10.0)
        
        applyFilters([blurFilter, posterFilter, colorFilter, motionFilter], to: layer)
        
        // Overlays
        let (scanline, noise) = overlays.createVHSOverlays(size: layer.bounds.size)
        layer.addSublayer(scanline)
        layer.addSublayer(noise)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeOut)
        
        // Animate Filters
        let blurAnim = createAnimation(keyPath: "filters.CIGaussianBlur.inputRadius", from: 3.0, to: 0.0, duration: duration)
        blurAnim.fillMode = .forwards
        blurAnim.isRemovedOnCompletion = false
        blurAnim.delegate = AnimationCompletionDelegate { [weak self] finished in
            guard let self, finished else { return }
            self.clearFilters(from: layer)
            scanline.removeFromSuperlayer()
            noise.removeFromSuperlayer()
            completion?()
        }
        layer.add(blurAnim, forKey: "blur")
        
        addForwardAnimation(keyPath: "filters.CIColorPosterize.inputLevels", from: 8.0, to: 256.0, duration: duration, to: layer)
        addForwardAnimation(keyPath: "filters.CIMotionBlur.inputRadius", from: 10.0, to: 0.0, duration: duration, to: layer)

        // Animate Overlays Opacity
        addForwardAnimation(keyPath: "opacity", from: 0.3, to: 0.0, duration: duration, to: scanline)
        addForwardAnimation(keyPath: "opacity", from: 0.15, to: 0.0, duration: duration, to: noise)
        
        scanline.opacity = 0.0
        noise.opacity = 0.0
        
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

        // Filters
        let blurFilter = FilterBuilder.gaussianBlur(radius: 0.0)
        let posterFilter = FilterBuilder.colorPosterize(levels: 256.0)
        let colorFilter = FilterBuilder.colorControls(saturation: 1.0)
        let motionFilter = FilterBuilder.motionBlur(radius: 0.0)
        
        applyFilters([blurFilter, posterFilter, colorFilter, motionFilter], to: layer)
        
        // Overlays (start invisible)
        let (scanline, noise) = overlays.createVHSOverlays(size: layer.bounds.size)
        scanline.opacity = 0.0
        noise.opacity = 0.0
        layer.addSublayer(scanline)
        layer.addSublayer(noise)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeIn)
        
        // Animate Filters
        let blurAnim = createAnimation(keyPath: "filters.CIGaussianBlur.inputRadius", from: 0.0, to: 3.0, duration: duration)
        blurAnim.fillMode = .forwards
        blurAnim.isRemovedOnCompletion = false
        blurAnim.delegate = AnimationCompletionDelegate { [weak self] finished in
            guard let self, finished else { return }
            self.clearFilters(from: layer)
            scanline.removeFromSuperlayer()
            noise.removeFromSuperlayer()
            completion?()
        }

        layer.add(blurAnim, forKey: "blur")
        
        addForwardAnimation(keyPath: "filters.CIColorPosterize.inputLevels", from: 256.0, to: 8.0, duration: duration, to: layer)
        addForwardAnimation(keyPath: "filters.CIMotionBlur.inputRadius", from: 0.0, to: 10.0, duration: duration, to: layer)

        // Animate Overlays Opacity
        addForwardAnimation(keyPath: "opacity", from: 0.0, to: 0.3, duration: duration, to: scanline)
        addForwardAnimation(keyPath: "opacity", from: 0.0, to: 0.15, duration: duration, to: noise)
        
        scanline.opacity = 0.3
        noise.opacity = 0.15
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
    }

    // MARK: - Private

    private func addForwardAnimation(keyPath: String,
                                     from fromValue: Any,
                                     to toValue: Any,
                                     duration: TimeInterval,
                                     to targetLayer: CALayer) {
        let anim = createAnimation(keyPath: keyPath,
                                   from: fromValue,
                                   to: toValue,
                                   duration: duration)

        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        targetLayer.add(anim, forKey: nil)
    }
}
