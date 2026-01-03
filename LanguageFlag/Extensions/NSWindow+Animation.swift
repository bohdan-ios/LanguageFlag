import Cocoa

enum SlideDirection {
    case up, down, left, right
}

protocol Animatable {

    func fadeIn(duration: TimeInterval, completion: (() -> Void)?)
    func fadeOut(duration: TimeInterval, completion: (() -> Void)?)
    func slideIn(duration: TimeInterval, direction: SlideDirection, maxDistance: CGFloat?, completion: (() -> Void)?)
    func slideOut(duration: TimeInterval, direction: SlideDirection, maxDistance: CGFloat?, completion: (() -> Void)?)
    func scaleIn(duration: TimeInterval, completion: (() -> Void)?)
    func scaleOut(duration: TimeInterval, completion: (() -> Void)?)
    func pixelateIn(duration: TimeInterval, completion: (() -> Void)?)
    func pixelateOut(duration: TimeInterval, completion: (() -> Void)?)
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

    func slideIn(duration: TimeInterval, direction: SlideDirection = .up, maxDistance: CGFloat? = nil, completion: (() -> Void)? = nil) {
        // Store original frame
        let originalFrame = self.frame

        // Start with window off-screen in the specified direction
        // Use maxDistance if provided, otherwise use window dimension
        var startFrame = originalFrame
        switch direction {
        case .up:
            let distance = maxDistance ?? originalFrame.height
            startFrame.origin.y -= distance
        case .down:
            let distance = maxDistance ?? originalFrame.height
            startFrame.origin.y += distance
        case .left:
            let distance = maxDistance ?? originalFrame.width
            startFrame.origin.x -= distance
        case .right:
            let distance = maxDistance ?? originalFrame.width
            startFrame.origin.x += distance
        }

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

    func slideOut(duration: TimeInterval, direction: SlideDirection = .down, maxDistance: CGFloat? = nil, completion: (() -> Void)? = nil) {
        let currentFrame = self.frame
        var endFrame = currentFrame

        // Move window off-screen in the specified direction
        // Use maxDistance if provided, otherwise use window dimension + extra distance
        let extraDistance: CGFloat = 50
        switch direction {
        case .up:
            let distance = maxDistance ?? (currentFrame.height + extraDistance)
            endFrame.origin.y += distance
        case .down:
            let distance = maxDistance ?? (currentFrame.height + extraDistance)
            endFrame.origin.y -= distance
        case .left:
            let distance = maxDistance ?? (currentFrame.width + extraDistance)
            endFrame.origin.x -= distance
        case .right:
            let distance = maxDistance ?? (currentFrame.width + extraDistance)
            endFrame.origin.x += distance
        }

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().setFrame(endFrame, display: true)
            self.animator().alphaValue = 0
        }, completionHandler: completion)
    }

    func scaleIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        // Store original frame
        let originalFrame = self.frame

        // Calculate center point
        let centerX = originalFrame.midX
        let centerY = originalFrame.midY

        // Start with small scale (20% of original size for better visibility)
        let scale: CGFloat = 0.2
        var startFrame = originalFrame
        startFrame.size.width *= scale
        startFrame.size.height *= scale
        // Position at center
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

        // End with small scale (20% of original size)
        let scale: CGFloat = 0.2
        var endFrame = currentFrame
        endFrame.size.width *= scale
        endFrame.size.height *= scale
        // Position at center
        endFrame.origin.x = centerX - endFrame.width / 2
        endFrame.origin.y = centerY - endFrame.height / 2

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().setFrame(endFrame, display: true)
            self.animator().alphaValue = 0
        }, completionHandler: completion)
    }

    func pixelateIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        // Ensure window is at correct position
        self.orderFrontRegardless()
        self.alphaValue = 1

        guard let contentView = self.contentView else { return }

        // Enable layer and create pixelation effect using CIFilter
        contentView.wantsLayer = true
        guard let layer = contentView.layer else { return }

        // Create pixelate filter
        let pixelateFilter = CIFilter(name: "CIPixellate")
        pixelateFilter?.setDefaults()

        // Start with large pixels (very pixelated)
        let startScale: CGFloat = 50.0
        pixelateFilter?.setValue(startScale, forKey: kCIInputScaleKey)

        // Use filters (not backgroundFilters) to apply to the content itself
        layer.filters = [pixelateFilter!]

        // Animate from pixelated to normal
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
        CATransaction.setCompletionBlock {
            // Remove filter after animation
            layer.filters = nil
            completion?()
        }

        // Animate the pixelation scale from 50 to 1 (less pixelated)
        let scaleAnimation = CABasicAnimation(keyPath: "filters.CIPixellate.inputScale")
        scaleAnimation.fromValue = startScale
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(scaleAnimation, forKey: "pixelate")

        // Also animate opacity from 0 to 1 for smooth appearance
        contentView.alphaValue = 0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            contentView.animator().alphaValue = 1
        })

        CATransaction.commit()

        // Update filter value (for non-animated fallback)
        pixelateFilter?.setValue(1.0, forKey: kCIInputScaleKey)
    }

    func pixelateOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard let contentView = self.contentView else { return }

        // Enable layer and create pixelation effect
        contentView.wantsLayer = true
        guard let layer = contentView.layer else { return }

        // Create pixelate filter
        let pixelateFilter = CIFilter(name: "CIPixellate")
        pixelateFilter?.setDefaults()

        // Start with normal (no pixelation)
        pixelateFilter?.setValue(1.0, forKey: kCIInputScaleKey)
        layer.filters = [pixelateFilter!]

        // Animate to pixelated
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeIn))
        CATransaction.setCompletionBlock {
            // Remove filter after animation
            layer.filters = nil
            completion?()
        }

        // Animate the pixelation scale from 1 to 50 (more pixelated)
        let endScale: CGFloat = 50.0
        let scaleAnimation = CABasicAnimation(keyPath: "filters.CIPixellate.inputScale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = endScale
        scaleAnimation.duration = duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        layer.add(scaleAnimation, forKey: "pixelate")

        // Fade out simultaneously
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            contentView.animator().alphaValue = 0
        })

        CATransaction.commit()

        // Update filter value (for non-animated fallback)
        pixelateFilter?.setValue(endScale, forKey: kCIInputScaleKey)
    }
}
