import Cocoa

/// Type-safe builder for creating and configuring CIFilters
/// Provides a clean, Swift-friendly API for filter creation
enum FilterBuilder {
    
    // MARK: - Blur Filters
    
    /// Creates a Gaussian blur filter
    /// - Parameter radius: Blur radius (0 = no blur, higher = more blur)
    /// - Returns: Configured CIFilter
    static func gaussianBlur(radius: CGFloat) -> CIFilter {
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setDefaults()
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        return filter
    }
    
    /// Creates a motion blur filter
    /// - Parameters:
    ///   - radius: Blur radius
    ///   - angle: Blur angle in radians
    /// - Returns: Configured CIFilter
    static func motionBlur(radius: CGFloat, angle: CGFloat = 0.0) -> CIFilter {
        let filter = CIFilter(name: "CIMotionBlur")!
        filter.setDefaults()
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        filter.setValue(angle, forKey: kCIInputAngleKey)
        return filter
    }
    
    /// Creates a zoom blur filter (radial blur from center)
    /// - Parameters:
    ///   - amount: Blur amount
    ///   - center: Center point of the blur
    /// - Returns: Configured CIFilter
    static func zoomBlur(amount: CGFloat, center: CIVector) -> CIFilter {
        let filter = CIFilter(name: "CIZoomBlur")!
        filter.setDefaults()
        filter.setValue(amount, forKey: kCIInputAmountKey)
        filter.setValue(center, forKey: kCIInputCenterKey)
        return filter
    }
    
    // MARK: - Pixelation & Stylize
    
    /// Creates a pixelate filter
    /// - Parameter scale: Pixel size (1 = normal, higher = more pixelated)
    /// - Returns: Configured CIFilter
    static func pixellate(scale: CGFloat) -> CIFilter {
        let filter = CIFilter(name: "CIPixellate")!
        filter.setDefaults()
        filter.setValue(scale, forKey: kCIInputScaleKey)
        return filter
    }
    
    /// Creates a color posterize filter
    /// - Parameter levels: Number of color levels (lower = more posterized)
    /// - Returns: Configured CIFilter
    static func colorPosterize(levels: CGFloat) -> CIFilter {
        let filter = CIFilter(name: "CIColorPosterize")!
        filter.setDefaults()
        filter.setValue(levels, forKey: "inputLevels")
        return filter
    }
    
    // MARK: - Color Adjustments
    
    /// Creates a color controls filter
    /// - Parameters:
    ///   - saturation: Saturation multiplier (1.0 = normal)
    ///   - brightness: Brightness adjustment (-1.0 to 1.0)
    ///   - contrast: Contrast multiplier (1.0 = normal)
    /// - Returns: Configured CIFilter
    static func colorControls(
        saturation: CGFloat = 1.0,
        brightness: CGFloat = 0.0,
        contrast: CGFloat = 1.0
    ) -> CIFilter {
        let filter = CIFilter(name: "CIColorControls")!
        filter.setDefaults()
        filter.setValue(saturation, forKey: "inputSaturation")
        filter.setValue(brightness, forKey: "inputBrightness")
        filter.setValue(contrast, forKey: "inputContrast")
        return filter
    }
    
    /// Creates a hue adjust filter
    /// - Parameter angle: Hue rotation angle in radians
    /// - Returns: Configured CIFilter
    static func hueAdjust(angle: CGFloat) -> CIFilter {
        let filter = CIFilter(name: "CIHueAdjust")!
        filter.setDefaults()
        filter.setValue(angle, forKey: "inputAngle")
        return filter
    }
    
    // MARK: - Distortion
    
    /// Creates a twirl distortion filter
    /// - Parameters:
    ///   - center: Center point of the effect
    ///   - radius: Effect radius
    ///   - angle: Twirl angle in radians
    /// - Returns: Configured CIFilter
    static func twirlDistortion(center: CIVector, radius: CGFloat, angle: CGFloat) -> CIFilter {
        let filter = CIFilter(name: "CITwirlDistortion")!
        filter.setDefaults()
        filter.setValue(center, forKey: kCIInputCenterKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        filter.setValue(angle, forKey: kCIInputAngleKey)
        return filter
    }
    
    /// Creates a circle splash distortion filter
    /// - Parameters:
    ///   - center: Center point of the splash
    ///   - radius: Splash radius
    /// - Returns: Configured CIFilter
    static func circleSplashDistortion(center: CIVector, radius: CGFloat) -> CIFilter {
        let filter = CIFilter(name: "CICircleSplashDistortion")!
        filter.setDefaults()
        filter.setValue(center, forKey: kCIInputCenterKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        return filter
    }
    
    // MARK: - Morphology
    
    /// Creates a morphology maximum filter (ink spread effect)
    /// - Parameter radius: Effect radius
    /// - Returns: Configured CIFilter
    static func morphologyMaximum(radius: CGFloat) -> CIFilter {
        let filter = CIFilter(name: "CIMorphologyMaximum")!
        filter.setDefaults()
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        return filter
    }
    
    // MARK: - Special Effects
    
    /// Creates a bloom filter (glow effect)
    /// - Parameters:
    ///   - intensity: Bloom intensity
    ///   - radius: Bloom radius
    /// - Returns: Configured CIFilter
    static func bloom(intensity: CGFloat, radius: CGFloat) -> CIFilter {
        let filter = CIFilter(name: "CIBloom")!
        filter.setDefaults()
        filter.setValue(intensity, forKey: kCIInputIntensityKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        return filter
    }
}
