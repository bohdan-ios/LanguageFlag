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
    func blurIn(duration: TimeInterval, completion: (() -> Void)?)
    func blurOut(duration: TimeInterval, completion: (() -> Void)?)
    func flipIn(duration: TimeInterval, completion: (() -> Void)?)
    func flipOut(duration: TimeInterval, completion: (() -> Void)?)
    func bounceIn(duration: TimeInterval, completion: (() -> Void)?)
    func bounceOut(duration: TimeInterval, completion: (() -> Void)?)
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

    // MARK: - Blur Animations
    func blurIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        self.orderFrontRegardless()
        self.alphaValue = 1

        guard let contentView = self.contentView else { return }

        contentView.wantsLayer = true
        guard let layer = contentView.layer else { return }

        // Create gaussian blur filter
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setDefaults()

        // Start with heavy blur
        let startBlur: CGFloat = 20.0
        blurFilter?.setValue(startBlur, forKey: kCIInputRadiusKey)

        layer.filters = [blurFilter!]

        // Animate from blurred to sharp
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
        CATransaction.setCompletionBlock {
            layer.filters = nil
            completion?()
        }

        let blurAnimation = CABasicAnimation(keyPath: "filters.CIGaussianBlur.inputRadius")
        blurAnimation.fromValue = startBlur
        blurAnimation.toValue = 0.0
        blurAnimation.duration = duration
        blurAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(blurAnimation, forKey: "blur")

        // Fade in simultaneously
        contentView.alphaValue = 0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            contentView.animator().alphaValue = 1
        })

        CATransaction.commit()

        blurFilter?.setValue(0.0, forKey: kCIInputRadiusKey)
    }

    func blurOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard let contentView = self.contentView else { return }

        contentView.wantsLayer = true
        guard let layer = contentView.layer else { return }

        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setDefaults()
        blurFilter?.setValue(0.0, forKey: kCIInputRadiusKey)
        layer.filters = [blurFilter!]

        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeIn))
        CATransaction.setCompletionBlock {
            layer.filters = nil
            completion?()
        }

        let endBlur: CGFloat = 20.0
        let blurAnimation = CABasicAnimation(keyPath: "filters.CIGaussianBlur.inputRadius")
        blurAnimation.fromValue = 0.0
        blurAnimation.toValue = endBlur
        blurAnimation.duration = duration
        blurAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        layer.add(blurAnimation, forKey: "blur")

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            contentView.animator().alphaValue = 0
        })

        CATransaction.commit()

        blurFilter?.setValue(endBlur, forKey: kCIInputRadiusKey)
    }

    // MARK: - Flip Animations
    func flipIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard let contentView = self.contentView else { return }

        contentView.wantsLayer = true
        guard let layer = contentView.layer else { return }

        // Set anchor point to top for vertical flip
        let originalFrame = layer.frame
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0) // Anchor at top center
        layer.frame = originalFrame

        // Keep fully visible during flip
        contentView.alphaValue = 1

        // Ensure window is visible
        self.orderFrontRegardless()
        self.alphaValue = 1

        // Create the starting transform (rotated -90 degrees)
        var startTransform = CATransform3DIdentity
        startTransform.m34 = -1.0 / 500.0 // Add perspective
        startTransform = CATransform3DRotate(startTransform, -.pi / 2, 1, 0, 0) // Rotate around X axis

        // Create animation from rotated to normal
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = startTransform
        animation.toValue = CATransform3DIdentity
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fillMode = .both

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        layer.add(animation, forKey: "flipIn")
        CATransaction.commit()

        // Set the final state
        layer.transform = CATransform3DIdentity
    }

    func flipOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard let contentView = self.contentView else { return }

        contentView.wantsLayer = true
        guard let layer = contentView.layer else { return }

        // Set anchor point to bottom for vertical flip out
        let originalFrame = layer.frame
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.0) // Anchor at bottom center
        layer.frame = originalFrame

        // Keep fully visible during flip
        contentView.alphaValue = 1

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            context.allowsImplicitAnimation = true

            // Rotate 90 degrees around X axis (flip up from bottom)
            var transform = CATransform3DIdentity
            transform.m34 = -1.0 / 500.0
            transform = CATransform3DRotate(transform, .pi / 2, 1, 0, 0)
            layer.transform = transform
        }, completionHandler: {
            // Reset transform
            layer.transform = CATransform3DIdentity
            layer.anchorPoint = CGPoint(x: 0, y: 0)
            layer.frame = originalFrame
            completion?()
        })
    }

    // MARK: - Bounce Animations
    func bounceIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        // Store original frame
        let originalFrame = self.frame

        // Calculate center point
        let centerX = originalFrame.midX
        let centerY = originalFrame.midY

        // Start with small scale
        let startScale: CGFloat = 0.3
        var startFrame = originalFrame
        startFrame.size.width *= startScale
        startFrame.size.height *= startScale
        startFrame.origin.x = centerX - startFrame.width / 2
        startFrame.origin.y = centerY - startFrame.height / 2

        self.setFrame(startFrame, display: false)
        self.orderFrontRegardless()
        self.alphaValue = 0

        // Create keyframe animation with bounce effect
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.duration = duration
        animation.values = [0.3, 1.2, 0.9, 1.05, 0.98, 1.0] // Bounce sequence
        animation.keyTimes = [0.0, 0.4, 0.6, 0.75, 0.9, 1.0]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]

        guard let contentView = self.contentView else { return }
        contentView.wantsLayer = true
        contentView.layer?.add(animation, forKey: "bounce")

        // Animate frame and opacity
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().setFrame(originalFrame, display: true)
            self.animator().alphaValue = 1
        }, completionHandler: completion)
    }

    func bounceOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        let currentFrame = self.frame

        // Calculate center point
        let centerX = currentFrame.midX
        let centerY = currentFrame.midY

        // End with small scale
        let endScale: CGFloat = 0.3
        var endFrame = currentFrame
        endFrame.size.width *= endScale
        endFrame.size.height *= endScale
        endFrame.origin.x = centerX - endFrame.width / 2
        endFrame.origin.y = centerY - endFrame.height / 2

        // Create reverse bounce animation (compress)
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.duration = duration
        animation.values = [1.0, 1.05, 0.9, 0.5, 0.3] // Compress sequence
        animation.keyTimes = [0.0, 0.2, 0.4, 0.7, 1.0]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeIn),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeIn)
        ]

        guard let contentView = self.contentView else { return }
        contentView.wantsLayer = true
        contentView.layer?.add(animation, forKey: "bounce")

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().setFrame(endFrame, display: true)
            self.animator().alphaValue = 0
        }, completionHandler: completion)
    }
}
