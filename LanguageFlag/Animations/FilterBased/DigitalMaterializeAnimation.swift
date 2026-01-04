import Cocoa

/// Digital Materialize animation using Gradient Mask and Bloom
class DigitalMaterializeAnimation: BaseWindowAnimation, WindowAnimation {
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        guard
            let layer = prepareLayer(from: window),
            let contentView = window.contentView
        else {
            completion?()
            return
        }
        
        // Setup Filters
        // Start: Brightness 0.3 (Legacy), Bloom 1.0
        let bloomFilter = FilterBuilder.bloom(intensity: 1.0, radius: 10.0)
        let colorFilter = FilterBuilder.colorControls(saturation: 1.0, brightness: 0.3)
        applyFilters([bloomFilter, colorFilter], to: layer)
        
        // Setup Mask Layer (Legacy Colors)
        let maskLayer = CAGradientLayer()
        maskLayer.frame = layer.bounds
        maskLayer.colors = [NSColor.clear.cgColor, NSColor.white.cgColor, NSColor.white.cgColor]
        maskLayer.locations = [0.95, 1.0, 1.0] // Start at bottom
        maskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        maskLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.mask = maskLayer
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.linear)
        CATransaction.setCompletionBlock {
            layer.mask = nil
            self.clearFilters(from: layer)
            completion?()
        }
        
        // Animate Mask from bottom to top (build up)
        let maskAnim = createAnimation(keyPath: "locations", from: [0.95, 1.0, 1.0], to: [0.0, 0.0, 0.05], duration: duration)
        maskAnim.fillMode = .forwards
        maskAnim.isRemovedOnCompletion = false
        maskLayer.add(maskAnim, forKey: "scanline")
        maskLayer.locations = [0.0, 0.0, 0.05] // Final state (Model matches End for Mask, but safe to persist)
        
        // Animate Bloom intensity down (1.0 -> 0.0)
        let bloomAnim = createAnimation(keyPath: "filters.CIBloom.inputIntensity", from: 1.0, to: 0.0, duration: duration)
        bloomAnim.fillMode = .forwards
        bloomAnim.isRemovedOnCompletion = false
        layer.add(bloomAnim, forKey: "bloom")
        
        // Animate Brightness to normal (0.3 -> 0.0)
        // Note: Model value is 0.3. Animation goes to 0.0. Without forwards fill, it snaps to 0.3 before removal.
        let brightnessAnim = createAnimation(keyPath: "filters.CIColorControls.inputBrightness", from: 0.3, to: 0.0, duration: duration)
        brightnessAnim.fillMode = .forwards
        brightnessAnim.isRemovedOnCompletion = false
        layer.add(brightnessAnim, forKey: "brightness")
        
        CATransaction.commit()
    }
    
    func animateOut(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        guard let layer = prepareLayer(from: window),
              window.contentView != nil else {
            completion?()
            return
        }
        
        // Setup Filters
        // Start: Normal (Brightness 0.0, Bloom 0.0)
        let bloomFilter = FilterBuilder.bloom(intensity: 0.0, radius: 10.0)
        let colorFilter = FilterBuilder.colorControls(saturation: 1.0, brightness: 0.0)
        applyFilters([bloomFilter, colorFilter], to: layer)
        
        // Setup Mask Layer
        let maskLayer = CAGradientLayer()
        maskLayer.frame = layer.bounds
        maskLayer.colors = [NSColor.clear.cgColor, NSColor.white.cgColor, NSColor.white.cgColor]
        maskLayer.locations = [0.0, 0.0, 0.05] // Start fully visible
        maskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        maskLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.mask = maskLayer
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.linear)
        CATransaction.setCompletionBlock {
            layer.mask = nil
            self.clearFilters(from: layer)
            completion?()
        }
        
        // Animate Mask from top to bottom (dematerialize)
        let maskAnim = createAnimation(keyPath: "locations", from: [0.0, 0.0, 0.05], to: [0.95, 1.0, 1.0], duration: duration)
        maskAnim.fillMode = .forwards
        maskAnim.isRemovedOnCompletion = false
        maskLayer.add(maskAnim, forKey: "scanline")
        maskLayer.locations = [0.95, 1.0, 1.0] // Final state
        
        // Animate Bloom intensity up (0.0 -> 1.0)
        let bloomAnim = createAnimation(keyPath: "filters.CIBloom.inputIntensity", from: 0.0, to: 1.0, duration: duration)
        bloomAnim.fillMode = .forwards
        bloomAnim.isRemovedOnCompletion = false
        layer.add(bloomAnim, forKey: "bloom")
        
        // Animate Brightness up (0.0 -> 0.3)
        let brightnessAnim = createAnimation(keyPath: "filters.CIColorControls.inputBrightness", from: 0.0, to: 0.3, duration: duration)
        brightnessAnim.fillMode = .forwards
        brightnessAnim.isRemovedOnCompletion = false
        layer.add(brightnessAnim, forKey: "brightness")
        
        CATransaction.commit()
    }
}
