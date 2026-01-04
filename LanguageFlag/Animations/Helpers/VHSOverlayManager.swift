import Cocoa

/// Manager for creating VHS-style overlay layers (scanlines and noise)
class VHSOverlayManager {
    
    // MARK: - Scanline Layer
    
    /// Creates a layer with horizontal scanlines for VHS effect
    /// - Parameters:
    ///   - size: Size of the layer to create
    ///   - opacity: Initial opacity of the layer
    /// - Returns: CALayer with scanline pattern
    func createScanlineLayer(size: CGSize, opacity: Float = 0.3) -> CALayer {
        let layer = CALayer()
        layer.name = "vhsScanline"
        layer.frame = CGRect(origin: .zero, size: size)
        layer.contents = AnimationEffectHelpers.createScanlinePattern(size: size)
        layer.opacity = opacity
        return layer
    }
    
    // MARK: - Noise Layer
    
    /// Creates a layer with random noise for VHS static effect
    /// - Parameters:
    ///   - size: Size of the layer to create
    ///   - opacity: Initial opacity of the layer
    /// - Returns: CALayer with noise pattern
    func createNoiseLayer(size: CGSize, opacity: Float = 0.15) -> CALayer {
        let layer = CALayer()
        layer.name = "vhsNoise"
        layer.frame = CGRect(origin: .zero, size: size)
        layer.contents = AnimationEffectHelpers.createNoisePattern(size: size)
        layer.opacity = opacity
        return layer
    }
    
    // MARK: - Combined Setup
    
    /// Creates both scanline and noise layers for complete VHS effect
    /// - Parameter size: Size for both layers
    /// - Returns: Tuple of (scanline layer, noise layer)
    func createVHSOverlays(size: CGSize) -> (scanline: CALayer, noise: CALayer) {
        let scanline = createScanlineLayer(size: size)
        let noise = createNoiseLayer(size: size)
        return (scanline, noise)
    }
}
