import Cocoa

/// Manager for creating VHS-style overlay layers (scanlines and noise).
///
/// Generated images are cached by size so that repeated `animateIn`/`animateOut`
/// calls reuse the same bitmaps instead of regenerating them each time.
class VHSOverlayManager {

    // MARK: - Cache

    private var scanlineCache: [CGSize: CGImage] = [:]
    private var noiseCache: [CGSize: CGImage] = [:]

    // MARK: - Scanline Layer

    /// Creates a layer with horizontal scanlines for VHS effect
    /// - Parameters:
    ///   - size: Size of the layer to create
    ///   - opacity: Initial opacity of the layer
    /// - Returns: CALayer with scanline pattern
    func createScanlineLayer(size: CGSize, opacity: Float = 0.3) -> CALayer {
        let image = scanlineCache[size] ?? {
            let img = AnimationEffectHelpers.createScanlinePattern(size: size)
            scanlineCache[size] = img
            return img
        }()
        let layer = CALayer()
        layer.name = "vhsScanline"
        layer.frame = CGRect(origin: .zero, size: size)
        layer.contents = image
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
        let image = noiseCache[size] ?? {
            let img = AnimationEffectHelpers.createNoisePattern(size: size)
            noiseCache[size] = img
            return img
        }()
        let layer = CALayer()
        layer.name = "vhsNoise"
        layer.frame = CGRect(origin: .zero, size: size)
        layer.contents = image
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
