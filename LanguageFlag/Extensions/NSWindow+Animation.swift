import Cocoa

protocol Animatable {

    func fadeIn(duration: TimeInterval, completion: (() -> Void)?)
    func fadeOut(duration: TimeInterval, completion: (() -> Void)?)
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
}
