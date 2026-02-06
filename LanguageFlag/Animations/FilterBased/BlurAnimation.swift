import Cocoa

/// Blur animation using Gaussian blur filter
class BlurAnimation: BaseWindowAnimation, WindowAnimation {
    
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
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeOut)
        CATransaction.setCompletionBlock {
            self.clearFilters(from: layer)
            completion?()
        }
        
        let animation = createAnimation(keyPath: "filters.CIGaussianBlur.inputRadius",
                                       from: 20.0, to: 0.0, duration: duration)
        layer.add(animation, forKey: "blur")
        
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
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(AnimationTiming.easeIn)
        CATransaction.setCompletionBlock {
            self.clearFilters(from: layer)
            completion?()
        }
        
        let animation = createAnimation(keyPath: "filters.CIGaussianBlur.inputRadius",
                                       from: 0.0, to: 20.0, duration: duration,
                                       timing: AnimationTiming.easeIn)
        layer.add(animation, forKey: "blur")
        
        CATransaction.commit()
        
        animateAlpha(contentView: contentView, from: 1.0, to: 0.0, duration: duration,
                    timing: AnimationTiming.easeIn)
    }
}
