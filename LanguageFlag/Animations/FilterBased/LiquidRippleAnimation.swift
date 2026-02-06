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
        
        // Use splash distortion filter
        let splashFilter = FilterBuilder.circleSplashDistortion(center: center, radius: 150.0)
        let colorFilter = FilterBuilder.colorControls(saturation: 1.3, brightness: 0.1)
        
        applyFilters([splashFilter, colorFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeOut)
        CATransaction.setCompletionBlock {
            self.clearFilters(from: layer)
            completion?()
        }
        
        // Animate splash radius (150 -> 0)
        let splashAnim = createAnimation(keyPath: "filters.CICircleSplashDistortion.inputRadius", from: 150.0, to: 0.0, duration: duration)
        splashAnim.fillMode = .forwards
        splashAnim.isRemovedOnCompletion = false
        layer.add(splashAnim, forKey: "splash")
        
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
        
        let splashFilter = FilterBuilder.circleSplashDistortion(center: center, radius: 0.0)
        let colorFilter = FilterBuilder.colorControls(saturation: 1.0, brightness: 0.0)
        
        applyFilters([splashFilter, colorFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeIn)
        CATransaction.setCompletionBlock {
            self.clearFilters(from: layer)
            completion?()
        }
        
        // Animate splash radius (0 -> 150)
        let splashAnim = createAnimation(keyPath: "filters.CICircleSplashDistortion.inputRadius", from: 0.0, to: 150.0, duration: duration)
        splashAnim.fillMode = .forwards
        splashAnim.isRemovedOnCompletion = false
        layer.add(splashAnim, forKey: "splash")
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration)
    }
}
