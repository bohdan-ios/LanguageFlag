import Cocoa

/// Pixelate animation using CIPixellate filter
class PixelateAnimation: BaseWindowAnimation, WindowAnimation {
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        guard
            let layer = prepareLayer(from: window),
            let contentView = window.contentView
        else {
            completion?()
            return
        }

        let pixelFilter = FilterBuilder.pixellate(scale: 1.0)
        applyFilters([pixelFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeOut)
        CATransaction.setCompletionBlock {
            self.clearFilters(from: layer)
            completion?()
        }
        
        let animation = createAnimation(keyPath: "filters.CIPixellate.inputScale",
                                       from: 50.0, to: 1.0, duration: duration)
        layer.add(animation, forKey: "pixelate")
        
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

        let pixelFilter = FilterBuilder.pixellate(scale: 50.0)
        applyFilters([pixelFilter], to: layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeIn)
        CATransaction.setCompletionBlock {
            self.clearFilters(from: layer)
            completion?()
        }
        
        let animation = createAnimation(keyPath: "filters.CIPixellate.inputScale",
                                       from: 1.0, to: 50.0, duration: duration,
                                       timing: AnimationTiming.easeIn)
        layer.add(animation, forKey: "pixelate")
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration,
                    timing: AnimationTiming.easeIn)
    }
}
