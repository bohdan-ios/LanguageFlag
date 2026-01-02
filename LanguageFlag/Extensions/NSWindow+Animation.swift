import Cocoa

protocol Animatable {

    func fadeIn(duration: TimeInterval, completion: (() -> Void)?)
    func fadeOut(duration: TimeInterval, completion: (() -> Void)?)
    func slideIn(duration: TimeInterval, completion: (() -> Void)?)
    func slideOut(duration: TimeInterval, completion: (() -> Void)?)
    func scaleIn(duration: TimeInterval, completion: (() -> Void)?)
    func scaleOut(duration: TimeInterval, completion: (() -> Void)?)
}

extension NSWindow: Animatable {

    func fadeIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        self.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            self.contentView?.animator().alphaValue = 1
            self.animator().alphaValue = 1
        }, completionHandler: completion)
    }

    func fadeOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            self.animator().alphaValue = 0
            self.contentView?.animator().alphaValue = 0
        }, completionHandler: completion)
    }

    func slideIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        // Store original frame
        let originalFrame = self.frame

        // Start with window off-screen (below current position)
        var startFrame = originalFrame
        startFrame.origin.y -= originalFrame.height

        self.setFrame(startFrame, display: false)
        self.orderFrontRegardless()
        self.alphaValue = 1

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().setFrame(originalFrame, display: true)
        }, completionHandler: completion)
    }

    func slideOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        let currentFrame = self.frame
        var endFrame = currentFrame
        endFrame.origin.y -= currentFrame.height

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().setFrame(endFrame, display: true)
        }, completionHandler: completion)
    }

    func scaleIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        // Store original frame
        let originalFrame = self.frame

        // Calculate center point
        let centerX = originalFrame.midX
        let centerY = originalFrame.midY

        // Start with small scale (10% of original size)
        let scale: CGFloat = 0.1
        var startFrame = originalFrame
        startFrame.size.width *= scale
        startFrame.size.height *= scale
        startFrame.origin.x = centerX - startFrame.width / 2
        startFrame.origin.y = centerY - startFrame.height / 2

        self.setFrame(startFrame, display: false)
        self.orderFrontRegardless()
        self.alphaValue = 0

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().setFrame(originalFrame, display: true)
            self.animator().alphaValue = 1
        }, completionHandler: completion)
    }

    func scaleOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        let currentFrame = self.frame

        // Calculate center point
        let centerX = currentFrame.midX
        let centerY = currentFrame.midY

        // End with small scale (10% of original size)
        let scale: CGFloat = 0.1
        var endFrame = currentFrame
        endFrame.size.width *= scale
        endFrame.size.height *= scale
        endFrame.origin.x = centerX - endFrame.width / 2
        endFrame.origin.y = centerY - endFrame.height / 2

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().setFrame(endFrame, display: true)
            self.animator().alphaValue = 0
        }, completionHandler: completion)
    }
}
