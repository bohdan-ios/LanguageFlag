import Cocoa

/// Presets for common animation timing functions
/// Provides consistent timing across all animations
enum AnimationTiming {
    
    // MARK: - Standard Timing Functions
    
    /// Ease in timing (slow start, fast end)
    static let easeIn = CAMediaTimingFunction(name: .easeIn)
    
    /// Ease out timing (fast start, slow end)
    static let easeOut = CAMediaTimingFunction(name: .easeOut)
    
    /// Ease in-ease out timing (slow start and end, fast middle)
    static let easeInOut = CAMediaTimingFunction(name: .easeInEaseOut)
    
    /// Linear timing (constant speed)
    static let linear = CAMediaTimingFunction(name: .linear)
    
    /// Default timing (system default, usually easeInOut)
    static let `default` = CAMediaTimingFunction(name: .default)
    
    // MARK: - Custom Cubic Bezier Curves
    
    /// Smooth ease out (gentler than standard)
    static let smoothEaseOut = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1.0)
    
    /// Sharp ease in (more aggressive than standard)
    static let sharpEaseIn = CAMediaTimingFunction(controlPoints: 0.75, 0.0, 0.75, 0.9)
    
    /// Bounce effect timing
    static let bounce = CAMediaTimingFunction(controlPoints: 0.68, -0.55, 0.265, 1.55)
    
    /// Elastic effect timing
    static let elastic = CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)
}
