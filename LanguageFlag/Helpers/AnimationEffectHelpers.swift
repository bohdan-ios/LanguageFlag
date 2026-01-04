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
    
    /// Creates a noise pattern image with random dots for VHS static effect
    /// - Parameter size: Size of the pattern image
    /// - Returns: CGImage with noise pattern, or nil if creation fails
    static func createNoisePattern(size: CGSize) -> CGImage? {
        let width = Int(size.width)
        let height = Int(size.height)
        let noiseDensity: Float = 0.8  // 80% of pixels will be noise
        
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
        
        // Add random noise dots
        for _ in 0..<Int(Float(width * height) * noiseDensity) {
            let x = Int.random(in: 0..<width)
            let y = Int.random(in: 0..<height)
            let brightness = CGFloat.random(in: 0.2...0.8)  // Random gray value
            
            context.setFillColor(gray: brightness, alpha: 1.0)
            context.fill(CGRect(x: x, y: y, width: 1, height: 1))
        }
        
        return context.makeImage()
    }
}
