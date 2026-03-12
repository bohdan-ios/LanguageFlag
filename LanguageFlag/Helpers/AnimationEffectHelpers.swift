import Cocoa

/// Utility functions for creating visual effects used in animations
enum AnimationEffectHelpers {

    // MARK: - VHS Effect Helpers
    
    /// Creates a scanline pattern image with horizontal gray lines for VHS effect
    /// - Parameter size: Size of the pattern image
    /// - Returns: CGImage with scanline pattern, or nil if creation fails
    static func createScanlinePattern(size: CGSize) -> CGImage? {
        let width = Int(size.width)
        let height = Int(size.height)
        let numberOfLines = Int(size.height / 20)
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGImageAlphaInfo.none.rawValue
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }
        
        // Fill with transparent
        context.setFillColor(gray: 1.0, alpha: 1.0)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        
        // Draw randomized scanlines (glitch style)
        for _ in 0..<numberOfLines {
            let lineH = CGFloat.random(in: 5...21) // Random height
            let lineW = CGFloat.random(in: 40...CGFloat(width)) // Random width (at least 50px)
            let lineX = CGFloat.random(in: -20...(CGFloat(width) - 50)) // Random X position
            let lineY = CGFloat.random(in: 0...CGFloat(height)) // Random Y position
            
            // Random darkness for each line to create depth
            let darkness = CGFloat.random(in: 0.0...0.4) 
            
            context.setFillColor(gray: darkness, alpha: 1.0)
            context.fill(CGRect(x: Int(lineX), y: Int(lineY), width: Int(lineW), height: Int(lineH)))
        }
        
        return context.makeImage()
    }
    
    /// Creates a noise pattern image with random dots for VHS static effect.
    ///
    /// Writes pixel values directly into a `UInt8` bitmap buffer instead of
    /// issuing one `CGContext.fill` call per pixel, reducing Core Graphics
    /// overhead from O(width × height) API calls down to a single `makeImage()`.
    ///
    /// - Parameter size: Size of the pattern image
    /// - Returns: CGImage with noise pattern, or nil if creation fails
    static func createNoisePattern(size: CGSize) -> CGImage? {
        let width = Int(size.width)
        let height = Int(size.height)
        guard width > 0, height > 0 else { return nil }

        let pixelCount = width * height
        let noiseDensity: Float = 0.8

        // Fill buffer with white, then scatter random gray values directly.
        // UInt8 range 51–204 maps to 0.2–0.8 brightness (same as the original).
        var pixels = [UInt8](repeating: 255, count: pixelCount)
        let noiseCount = Int(Float(pixelCount) * noiseDensity)
        for _ in 0..<noiseCount {
            pixels[Int.random(in: 0..<pixelCount)] = UInt8.random(in: 51...204)
        }

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGImageAlphaInfo.none.rawValue

        return pixels.withUnsafeMutableBytes { ptr in
            guard let context = CGContext(
                data: ptr.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            ) else { return nil }
            return context.makeImage()
        }
    }
}
