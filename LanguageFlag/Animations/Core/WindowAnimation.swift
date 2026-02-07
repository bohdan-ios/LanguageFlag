import Cocoa

/// Protocol defining the contract for window animations
/// Implementations provide both "in" (appear) and "out" (disappear) animations
protocol WindowAnimation {

    /// Animates the window appearing
    /// - Parameters:
    ///   - window: The NSWindow to animate
    ///   - duration: Animation duration in seconds
    ///   - completion: Optional completion handler called when animation finishes
    func animateIn(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?)
    
    /// Animates the window disappearing
    /// - Parameters:
    ///   - window: The NSWindow to animate
    ///   - duration: Animation duration in seconds
    ///   - completion: Optional completion handler called when animation finishes
    func animateOut(window: NSWindow, duration: TimeInterval, completion: (() -> Void)?)
}
