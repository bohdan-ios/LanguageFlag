import Cocoa

/// Simple fade animation - opacity from 0 to 1 (in) or 1 to 0 (out)
class FadeAnimation: BaseWindowAnimation, WindowAnimation {
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        guard let contentView = window.contentView else {
            completion?()
            return
        }
        
        animateAlpha(
            contentView: contentView,
            from: 0.0,
            to: 1.0,
            duration: duration,
            timing: AnimationTiming.easeOut
        )
        
        completion?()
    }
    
    func animateOut(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        guard let contentView = window.contentView else {
            completion?()
            return
        }
        
        animateAlpha(
            contentView: contentView,
            from: 1.0,
            to: 0.0,
            duration: duration,
            timing: AnimationTiming.easeIn
        )
        
        completion?()
    }
}
