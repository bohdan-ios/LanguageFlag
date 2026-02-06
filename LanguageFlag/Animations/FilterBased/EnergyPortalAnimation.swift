import Cocoa

/// Energy Portal animation using Twirl Distortion and Zoom Blur
class EnergyPortalAnimation: BaseWindowAnimation, WindowAnimation {
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        guard let layer = prepareLayer(from: window),
              let contentView = window.contentView else {
            completion?()
            return
        }
        
        let center = CIVector(x: layer.bounds.midX, y: layer.bounds.midY)
        // Legacy: Radius 150.0
        let radius: CGFloat = 150.0
        
        // Legacy: Angle 3pi, Zoom 30, Sat 1.8, Bright 0.2
        let twirlFilter = FilterBuilder.twirlDistortion(center: center, radius: radius, angle: .pi * 3)
        let zoomFilter = FilterBuilder.zoomBlur(amount: 30.0, center: center)
        let colorFilter = FilterBuilder.colorControls(saturation: 1.8, brightness: 0.2)
        
        applyFilters([twirlFilter, zoomFilter, colorFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeOut)
        CATransaction.setCompletionBlock {
            self.clearFilters(from: layer)
            completion?()
        }
        
        // Animate twirl (3pi -> 0)
        let twirlAnim = createAnimation(keyPath: "filters.CITwirlDistortion.inputAngle", from: CGFloat.pi * 3, to: 0.0, duration: duration)
        twirlAnim.fillMode = .forwards
        twirlAnim.isRemovedOnCompletion = false
        layer.add(twirlAnim, forKey: "twirl")
        
        // Animate zoom (30 -> 0)
        let zoomAnim = createAnimation(keyPath: "filters.CIZoomBlur.inputAmount", from: 30.0, to: 0.0, duration: duration)
        zoomAnim.fillMode = .forwards
        zoomAnim.isRemovedOnCompletion = false
        layer.add(zoomAnim, forKey: "zoom")
        
        // Animate saturation (1.8 -> 1.0)
        let satAnim = createAnimation(keyPath: "filters.CIColorControls.inputSaturation", from: 1.8, to: 1.0, duration: duration)
        satAnim.fillMode = .forwards
        satAnim.isRemovedOnCompletion = false
        layer.add(satAnim, forKey: "saturation")
        
        // Animate brightness (0.2 -> 0.0)
        let brightAnim = createAnimation(keyPath: "filters.CIColorControls.inputBrightness", from: 0.2, to: 0.0, duration: duration)
        brightAnim.fillMode = .forwards
        brightAnim.isRemovedOnCompletion = false
        layer.add(brightAnim, forKey: "brightness")
        
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
        
        let center = CIVector(x: layer.bounds.midX, y: layer.bounds.midY)
        let radius: CGFloat = 150.0
        
        // Start: Normal (Sat 1.0, Bright 0.0)
        let twirlFilter = FilterBuilder.twirlDistortion(center: center, radius: radius, angle: 0.0)
        let zoomFilter = FilterBuilder.zoomBlur(amount: 0.0, center: center)
        let colorFilter = FilterBuilder.colorControls(saturation: 1.0, brightness: 0.0)
        
        applyFilters([twirlFilter, zoomFilter, colorFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeIn)
        CATransaction.setCompletionBlock {
            self.clearFilters(from: layer)
            completion?()
        }
        
        // Animate twirl (0 -> 3pi)
        let twirlAnim = createAnimation(keyPath: "filters.CITwirlDistortion.inputAngle", from: 0.0, to: CGFloat.pi * 3, duration: duration)
        twirlAnim.fillMode = .forwards
        twirlAnim.isRemovedOnCompletion = false
        layer.add(twirlAnim, forKey: "twirl")
        
        // Animate zoom (0 -> 30)
        let zoomAnim = createAnimation(keyPath: "filters.CIZoomBlur.inputAmount", from: 0.0, to: 30.0, duration: duration)
        zoomAnim.fillMode = .forwards
        zoomAnim.isRemovedOnCompletion = false
        layer.add(zoomAnim, forKey: "zoom")
        
        // Animate saturation (1.0 -> 1.8)
        let satAnim = createAnimation(keyPath: "filters.CIColorControls.inputSaturation", from: 1.0, to: 1.8, duration: duration)
        satAnim.fillMode = .forwards
        satAnim.isRemovedOnCompletion = false
        layer.add(satAnim, forKey: "saturation")
        
        // Animate brightness (0.0 -> 0.2)
        let brightAnim = createAnimation(keyPath: "filters.CIColorControls.inputBrightness", from: 0.0, to: 0.2, duration: duration)
        brightAnim.fillMode = .forwards
        brightAnim.isRemovedOnCompletion = false
        layer.add(brightAnim, forKey: "brightness")
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
    }
}
