import Cocoa

/// Base class providing common functionality for window animations
/// Subclasses can use these utilities to simplify animation implementation
class BaseWindowAnimation {
    
    // MARK: - Layer Preparation
    
    /// Prepares and returns the content view's layer for animation
    /// Ensures layer-backing is enabled
    /// - Parameter window: The window whose layer to prepare
    /// - Returns: The prepared CALayer, or nil if preparation fails
    func prepareLayer(from window: NSWindow) -> CALayer? {
        guard let contentView = window.contentView else { return nil }
        contentView.wantsLayer = true
        return contentView.layer
    }
    
    // MARK: - Window Setup
    
    /// Sets up the window for animation by ordering it to front and ensuring visibility
    /// Also performs deep cleanup of previous animation states
    /// - Parameter window: The window to set up
    func setupWindow(_ window: NSWindow) {
        // Deep Cleanup of previous state
        if let contentView = window.contentView, let layer = contentView.layer {
            layer.filters = nil
            layer.mask = nil
            layer.removeAllAnimations()
            
            // Remove VHS overlays if any
            layer.sublayers?.filter { $0.name == "vhsScanline" || $0.name == "vhsNoise" }
                .forEach { $0.removeFromSuperlayer() }
        }
        
        window.orderFrontRegardless()
        window.alphaValue = CGFloat(UserPreferences.shared.opacity)
    }
    
    // MARK: - Filter Application
    
    /// Applies an array of CIFilters to a layer
    /// - Parameters:
    ///   - filters: Array of filters to apply
    ///   - layer: The layer to apply filters to
    func applyFilters(_ filters: [CIFilter], to layer: CALayer) {
        layer.filters = filters
    }
    
    /// Removes all filters from a layer
    /// - Parameter layer: The layer to clear filters from
    func clearFilters(from layer: CALayer) {
        layer.filters = nil
        layer.removeAllAnimations()
    }
    
    // MARK: - Animation Utilities
    
    /// Creates a CABasicAnimation with common configuration
    /// - Parameters:
    ///   - keyPath: The key path to animate
    ///   - from: Starting value
    ///   - to: Ending value
    ///   - duration: Animation duration
    ///   - timing: Optional timing function (defaults to easeOut)
    /// - Returns: Configured CABasicAnimation
    func createAnimation(
        keyPath: String,
        from: Any,
        to: Any,
        duration: TimeInterval,
        timing: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeOut)
    ) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.timingFunction = timing
        return animation
    }
    
    /// Animates the alpha value of a content view
    /// - Parameters:
    ///   - contentView: The view to fade
    ///   - from: Starting alpha value
    ///   - to: Ending alpha value
    ///   - duration: Animation duration
    ///   - timing: Optional timing function
    func animateAlpha(
        contentView: NSView,
        from: CGFloat,
        to: CGFloat,
        duration: TimeInterval,
        timing: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeOut)
    ) {
        contentView.alphaValue = from
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = timing
            contentView.animator().alphaValue = to
        }
    }
}
