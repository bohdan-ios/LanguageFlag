import Cocoa

/// Scale animation - window scales from small to normal or normal to small
class ScaleAnimation: BaseWindowAnimation, WindowAnimation {
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        let originalFrame = window.frame
        let centerX = originalFrame.midX
        let centerY = originalFrame.midY
        
        // Start with small scale
        let startScale: CGFloat = 0.3
        var startFrame = originalFrame
        startFrame.size.width *= startScale
        startFrame.size.height *= startScale
        startFrame.origin.x = centerX - startFrame.width / 2
        startFrame.origin.y = centerY - startFrame.height / 2
        
        window.setFrame(startFrame, display: false, animate: false)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = AnimationTiming.easeOut
            window.animator().setFrame(originalFrame, display: true)
            window.animator().alphaValue = 1
        }, completionHandler: completion)
    }
    
    func animateOut(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        let currentFrame = window.frame
        let centerX = currentFrame.midX
        let centerY = currentFrame.midY
        
        // End with small scale
        let endScale: CGFloat = 0.3
        var endFrame = currentFrame
        endFrame.size.width *= endScale
        endFrame.size.height *= endScale
        endFrame.origin.x = centerX - endFrame.width / 2
        endFrame.origin.y = centerY - endFrame.height / 2
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = AnimationTiming.easeIn
            window.animator().setFrame(endFrame, display: true)
            window.animator().alphaValue = 0
        }, completionHandler: completion)
    }
}
