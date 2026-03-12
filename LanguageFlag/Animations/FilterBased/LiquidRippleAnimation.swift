import Cocoa

/// Liquid Ripple animation using Circle Splash Distortion
class LiquidRippleAnimation: BaseWindowAnimation, WindowAnimation {

    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        guard
            let layer = prepareLayer(from: window),
            let contentView = window.contentView
        else {
            completion?()
            return
        }
        
        let center = CIVector(x: layer.bounds.midX, y: layer.bounds.midY)
        
        // Use bump distortion filter for transparent lens ripple
        let bumpFilter = FilterBuilder.bumpDistortion(center: center, radius: 150.0, scale: 0.5)
        let colorFilter = FilterBuilder.colorControls(saturation: 1.3, brightness: 0.0)
        
        applyFilters([bumpFilter, colorFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeOut)
        
        // Animate bump radius (150 -> 0)
        let bumpAnim = createAnimation(keyPath: "filters.CIBumpDistortion.inputRadius", from: 150.0, to: 0.0, duration: duration)
        bumpAnim.fillMode = .forwards
        bumpAnim.isRemovedOnCompletion = false
        bumpAnim.delegate = AnimationCompletionDelegate { finished in
            guard finished else { return }
            layer.filters = nil
            layer.removeAllAnimations()
            completion?()
        }
        layer.add(bumpAnim, forKey: "bump")
        
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
        
        let bumpFilter = FilterBuilder.bumpDistortion(center: center, radius: 0.0, scale: 0.5)
        let colorFilter = FilterBuilder.colorControls(saturation: 1.0, brightness: 0.0)
        
        applyFilters([bumpFilter, colorFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeIn)
        
        // Animate bump radius (0 -> 150)
        let bumpAnim = createAnimation(keyPath: "filters.CIBumpDistortion.inputRadius", from: 0.0, to: 150.0, duration: duration)
        bumpAnim.fillMode = .forwards
        bumpAnim.isRemovedOnCompletion = false
        bumpAnim.delegate = AnimationCompletionDelegate { finished in
            guard finished else { return }
            layer.filters = nil
            layer.removeAllAnimations()
            completion?()
        }
        layer.add(bumpAnim, forKey: "bump")
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
    }
}
