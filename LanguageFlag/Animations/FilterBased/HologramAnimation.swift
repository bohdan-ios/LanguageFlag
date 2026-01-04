import Cocoa

/// Hologram animation using Color Controls, Hue Adjust, and Pixelate
class HologramAnimation: BaseWindowAnimation, WindowAnimation {
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        guard let layer = prepareLayer(from: window),
              let contentView = window.contentView else {
            completion?()
            return
        }
        
        // Create filters
        // Legacy: Saturation 1.5, Brightness 0.3, Hue 3.5, Pixel 8.0
        let colorFilter = FilterBuilder.colorControls(saturation: 1.5, brightness: 0.3)
        let hueFilter = FilterBuilder.hueAdjust(angle: 3.5)
        let pixelFilter = FilterBuilder.pixellate(scale: 8.0)
        
        applyFilters([colorFilter, hueFilter, pixelFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeOut)
        CATransaction.setCompletionBlock {
            // Legacy: Explicitly set final values before clearing?
            // Since we conform to Strategy, clearing is standard.
            // But we use fillMode.forwards to hold until clear.
            self.clearFilters(from: layer)
            completion?()
        }
        
        // Animate pixelation (8.0 -> 1.0)
        let pixelAnim = createAnimation(keyPath: "filters.CIPixellate.inputScale", from: 8.0, to: 1.0, duration: duration)
        pixelAnim.fillMode = .forwards
        pixelAnim.isRemovedOnCompletion = false
        layer.add(pixelAnim, forKey: "pixel")
        
        // Animate saturation (1.5 -> 1.0)
        let satAnim = createAnimation(keyPath: "filters.CIColorControls.inputSaturation", from: 1.5, to: 1.0, duration: duration)
        satAnim.fillMode = .forwards
        satAnim.isRemovedOnCompletion = false
        layer.add(satAnim, forKey: "saturation")
        
        // Animate brightness (0.3 -> 0.0)
        let brightAnim = createAnimation(keyPath: "filters.CIColorControls.inputBrightness", from: 0.3, to: 0.0, duration: duration)
        brightAnim.fillMode = .forwards
        brightAnim.isRemovedOnCompletion = false
        layer.add(brightAnim, forKey: "brightness")
        
        // Animate hue (3.5 -> 0.0)
        let hueAnim = createAnimation(keyPath: "filters.CIHueAdjust.inputAngle", from: 3.5, to: 0.0, duration: duration)
        hueAnim.fillMode = .forwards
        hueAnim.isRemovedOnCompletion = false
        layer.add(hueAnim, forKey: "hue")
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 0.0, to: 1.0, duration: duration)
    }
    
    func animateOut(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        guard let layer = prepareLayer(from: window),
              let contentView = window.contentView else {
            completion?()
            return
        }
        
        // Legacy Start: Normal (Sat 1.0, Bright 0.0, Hue 0.0, Pixel 1.0)
        let colorFilter = FilterBuilder.colorControls(saturation: 1.0, brightness: 0.0)
        let hueFilter = FilterBuilder.hueAdjust(angle: 0.0)
        let pixelFilter = FilterBuilder.pixellate(scale: 1.0)
        
        applyFilters([colorFilter, hueFilter, pixelFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeIn)
        CATransaction.setCompletionBlock {
            self.clearFilters(from: layer)
            completion?()
        }
        
        // Animate pixelation (1.0 -> 8.0)
        let pixelAnim = createAnimation(keyPath: "filters.CIPixellate.inputScale", from: 1.0, to: 8.0, duration: duration)
        pixelAnim.fillMode = .forwards
        pixelAnim.isRemovedOnCompletion = false
        layer.add(pixelAnim, forKey: "pixel")
        
        // Animate saturation (1.0 -> 1.5)
        let satAnim = createAnimation(keyPath: "filters.CIColorControls.inputSaturation", from: 1.0, to: 1.5, duration: duration)
        satAnim.fillMode = .forwards
        satAnim.isRemovedOnCompletion = false
        layer.add(satAnim, forKey: "saturation")
        
        // Animate brightness (0.0 -> 0.3)
        let brightAnim = createAnimation(keyPath: "filters.CIColorControls.inputBrightness", from: 0.0, to: 0.3, duration: duration)
        brightAnim.fillMode = .forwards
        brightAnim.isRemovedOnCompletion = false
        layer.add(brightAnim, forKey: "brightness")
        
        // Animate hue (0.0 -> 3.5)
        let hueAnim = createAnimation(keyPath: "filters.CIHueAdjust.inputAngle", from: 0.0, to: 3.5, duration: duration)
        hueAnim.fillMode = .forwards
        hueAnim.isRemovedOnCompletion = false
        layer.add(hueAnim, forKey: "hue")
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
    }
}
