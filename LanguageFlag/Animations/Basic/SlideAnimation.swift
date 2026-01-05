import Cocoa

/// Slide animation - window slides in from edge or out to edge
class SlideAnimation: BaseWindowAnimation, WindowAnimation {
    
    // Configuration properties
    var forcedDirection: SlideDirection?
    var forcedMaxDistance: CGFloat?
    
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        setupWindow(window)
        
        let currentFrame = window.frame
        let direction = forcedDirection ?? determineSlideDirection(for: window)
        let maxDistance = forcedMaxDistance ?? calculateMaxDistance(for: direction, frame: currentFrame)
        
        // Calculate start position (Legacy Logic)
        var startFrame = currentFrame
        switch direction {
        case .up:
            startFrame.origin.y += maxDistance // Start High (Top), Move Down
        case .down:
            startFrame.origin.y -= maxDistance // Start Low (Bottom), Move Up
        case .left:
            startFrame.origin.x -= maxDistance // Start Left, Move Right
        case .right:
            startFrame.origin.x += maxDistance // Start Right, Move Left
        }
        
        window.setFrame(startFrame, display: false, animate: false)
        window.alphaValue = 0

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = AnimationTiming.easeOut
            window.animator().setFrame(currentFrame, display: true)
            window.animator().alphaValue = CGFloat(UserPreferences.shared.opacity)
        }, completionHandler: completion)
    }
    
    func animateOut(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?) {
        let currentFrame = window.frame
        let direction = forcedDirection ?? determineSlideDirection(for: window)
        let maxDistance = forcedMaxDistance ?? calculateMaxDistance(for: direction, frame: currentFrame)
        
        // Calculate end position (Legacy Logic)
        var endFrame = currentFrame
        switch direction {
        case .up:
            endFrame.origin.y += maxDistance // Move Up (Pass through)
        case .down:
            endFrame.origin.y -= maxDistance // Move Down (Pass through)
        case .left:
            endFrame.origin.x -= maxDistance // Move Left (Drawer Close)
        case .right:
            endFrame.origin.x += maxDistance // Move Right (Drawer Close)
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = AnimationTiming.easeIn
            window.animator().setFrame(endFrame, display: true)
            window.animator().alphaValue = 0
        }, completionHandler: completion)
    }
    
    // MARK: - Helper Methods
    
    private func determineSlideDirection(for window: NSWindow) -> SlideDirection {
        guard let screen = window.screen else { return .down }
        
        let windowFrame = window.frame
        let screenFrame = screen.visibleFrame
        
        // Calculate distances to each edge (matching Controller logic)
        let distanceToTop = screenFrame.maxY - windowFrame.maxY
        let distanceToBottom = windowFrame.minY - screenFrame.minY
        let distanceToLeft = windowFrame.minX - screenFrame.minX
        let distanceToRight = screenFrame.maxX - windowFrame.maxX
        
        let minDistance = min(distanceToTop, distanceToBottom, distanceToLeft, distanceToRight)
        
        if minDistance == distanceToTop { return .up }
        if minDistance == distanceToBottom { return .down }
        if minDistance == distanceToLeft { return .left }
        return .right
    }
    
    private func calculateMaxDistance(for direction: SlideDirection, frame: CGRect) -> CGFloat {
        switch direction {
        case .up, .down:
            return frame.height + 50
        case .left, .right:
            return frame.width + 50
        }
    }
}
