import Cocoa

/// Coordinates window animations, encapsulating dispatch logic and completion handling
final class AnimationCoordinator {

    // MARK: - Variables
    private let positionCalculator = WindowPositionCalculator()
    private let preferences = UserPreferences.shared
    private var isShowing = false

    // Animation styles that need frame setup before animation
    private let stylesNeedingFrameSetup: Set<AnimationStyle> = [
        .slide, .scale, .pixelate, .bounce, .flip, .swing, .elastic,
        .hologram, .energyPortal, .digitalMaterialize, .liquidRipple, .inkDiffusion, .vhsGlitch
    ]

    // Animation styles that need frame reset after out animation
    private let stylesNeedingFrameReset: Set<AnimationStyle> = [
        .slide, .scale, .pixelate, .flip, .bounce, .swing,
        .hologram, .energyPortal, .digitalMaterialize, .liquidRipple, .inkDiffusion, .vhsGlitch
    ]

    // MARK: - Public Methods
    
    /// Performs the show animation for the window
    /// - Parameters:
    ///   - window: The window to animate
    ///   - style: The animation style to use
    ///   - duration: Animation duration
    ///   - screenRect: The screen's visible frame
    func animateIn(
        window: NSWindow,
        style: AnimationStyle,
        duration: TimeInterval,
        screenRect: CGRect
    ) {
        // If the window is already showing and reset is disabled,
        // let the current animation continue.
        // The flag image/title will still update (handled by LanguageViewController).
        if isShowing, !preferences.resetAnimationOnChange { return }
        isShowing = true

        // Set opacity before animation if window is being shown for first time
        if window.alphaValue == 0 {
            window.alphaValue = CGFloat(preferences.opacity)
        }

        // Set up frame for animations that need it
        if stylesNeedingFrameSetup.contains(style) {
            let targetFrame = positionCalculator.calculateWindowFrame(
                in: screenRect,
                position: preferences.displayPosition,
                size: preferences.windowSize
            )
            window.setFrame(targetFrame, display: false, animate: false)
        }

        // Dispatch to appropriate animation
        performInAnimation(window: window, style: style, duration: duration, screenRect: screenRect)
    }

    /// Performs the hide animation for the window
    /// - Parameters:
    ///   - window: The window to animate
    ///   - style: The animation style to use
    ///   - duration: Animation duration
    ///   - screenRect: The screen's visible frame
    ///   - completion: Optional completion handler
    func animateOut(
        window: NSWindow,
        style: AnimationStyle,
        duration: TimeInterval,
        screenRect: CGRect,
        completion: (() -> Void)? = nil
    ) {
        isShowing = false

        let frameResetCompletion: (() -> Void)? = stylesNeedingFrameReset.contains(style) ? { [weak self] in
            guard let self = self else { return }
            let targetFrame = self.positionCalculator.calculateWindowFrame(
                in: screenRect,
                position: self.preferences.displayPosition,
                size: self.preferences.windowSize
            )
            window.setFrame(targetFrame, display: false, animate: false)
            window.orderOut(nil)
            completion?()
        } : completion

        performOutAnimation(
            window: window,
            style: style,
            duration: duration,
            screenRect: screenRect,
            completion: frameResetCompletion
        )
    }
}

// MARK: - Private Animation Dispatch
private extension AnimationCoordinator {

    // swiftlint:disable:next cyclomatic_complexity
    func performInAnimation(
        window: NSWindow,
        style: AnimationStyle,
        duration: TimeInterval,
        screenRect: CGRect
    ) {
        switch style {
        case .fade:
            window.fadeIn(duration: duration)
        case .slide:
            let direction = positionCalculator.slideDirection(for: window.frame, in: screenRect)
            let maxDistance = positionCalculator.maxSlideDistance(for: direction, windowFrame: window.frame, screenRect: screenRect)
            window.slideIn(duration: duration, direction: direction, maxDistance: maxDistance)
        case .scale:
            window.scaleIn(duration: duration)
        case .pixelate:
            window.pixelateIn(duration: duration)
        case .blur:
            window.blurIn(duration: duration)
        case .flip:
            window.flipIn(duration: duration)
        case .bounce:
            window.bounceIn(duration: duration)
        case .rotate:
            window.rotateIn(duration: duration)
        case .swing:
            window.swingIn(duration: duration)
        case .elastic:
            window.elasticIn(duration: duration)
        case .hologram:
            window.hologramIn(duration: duration)
        case .energyPortal:
            window.energyPortalIn(duration: duration)
        case .digitalMaterialize:
            window.digitalMaterializeIn(duration: duration)
        case .liquidRipple:
            window.liquidRippleIn(duration: duration)
        case .inkDiffusion:
            window.inkDiffusionIn(duration: duration)
        case .vhsGlitch:
            window.vhsGlitchIn(duration: duration)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func performOutAnimation(
        window: NSWindow,
        style: AnimationStyle,
        duration: TimeInterval,
        screenRect: CGRect,
        completion: (() -> Void)?
    ) {
        switch style {
        case .fade:
            window.fadeOut(duration: duration)
            completion?()
        case .slide:
            let direction = positionCalculator.slideDirection(for: window.frame, in: screenRect)
            let maxDistance = positionCalculator.maxSlideDistance(for: direction, windowFrame: window.frame, screenRect: screenRect)
            window.slideOut(duration: duration, direction: direction, maxDistance: maxDistance, completion: completion)
        case .scale:
            window.scaleOut(duration: duration, completion: completion)
        case .pixelate:
            window.pixelateOut(duration: duration, completion: completion)
        case .blur:
            window.blurOut(duration: duration)
            completion?()
        case .flip:
            window.flipOut(duration: duration, completion: completion)
        case .bounce:
            window.bounceOut(duration: duration, completion: completion)
        case .rotate:
            window.rotateOut(duration: duration)
            completion?()
        case .swing:
            window.swingOut(duration: duration, completion: completion)
        case .elastic:
            window.elasticOut(duration: duration)
            completion?()
        case .hologram:
            window.hologramOut(duration: duration, completion: completion)
        case .energyPortal:
            window.energyPortalOut(duration: duration, completion: completion)
        case .digitalMaterialize:
            window.digitalMaterializeOut(duration: duration, completion: completion)
        case .liquidRipple:
            window.liquidRippleOut(duration: duration, completion: completion)
        case .inkDiffusion:
            window.inkDiffusionOut(duration: duration, completion: completion)
        case .vhsGlitch:
            window.vhsGlitchOut(duration: duration, completion: completion)
        }
    }
}
