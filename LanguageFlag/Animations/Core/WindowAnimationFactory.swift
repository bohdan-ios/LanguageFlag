import Cocoa

/// Factory for creating window animation instances
/// Uses the Strategy pattern to provide the appropriate animation for each style
class WindowAnimationFactory {

    // swiftlint:disable cyclomatic_complexity
    /// Creates and returns an animation instance for the specified style
    /// - Parameter style: The animation style to create
    /// - Returns: A WindowAnimation implementation
    static func animation(for style: AnimationStyle) -> WindowAnimation {
        switch style {
        // Basic animations
        case .fade:
            return FadeAnimation()
        case .slide:
            return SlideAnimation()
        case .scale:
            return ScaleAnimation()
            
        // Filter-based animations
        case .pixelate:
            return PixelateAnimation()
        case .blur:
            return BlurAnimation()
        case .hologram:
            return HologramAnimation()
        case .energyPortal:
            return EnergyPortalAnimation()
        case .digitalMaterialize:
            return DigitalMaterializeAnimation()
        case .liquidRipple:
            return LiquidRippleAnimation()
        case .inkDiffusion:
            return InkDiffusionAnimation()
        case .vhsGlitch:
            return VHSGlitchAnimation()
            
        // Transform-based animations
        case .flip:
            return FlipAnimation()
        case .bounce:
            return BounceAnimation()
        case .rotate:
            return RotateAnimation()
        case .swing:
            return SwingAnimation()
        case .elastic:
            return ElasticAnimation()
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
