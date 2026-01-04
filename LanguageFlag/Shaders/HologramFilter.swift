import CoreImage

class HologramFilter: CIFilter {

    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputTime: CGFloat = 0.0
    @objc dynamic var inputStrength: CGFloat = 1.0

    static var kernel: CIColorKernel = {
        let kernelString = """
            kernel vec4 hologramKernel(__sample s, float time, float strength) {
                vec4 original = s;

                // 1. Scanlines - horizontal lines moving vertically
                float yPos = destCoord().y;
                float scanline = sin(yPos * 0.3 + time * 10.0) * 0.5 + 0.5;
                scanline = pow(scanline, 2.0);

                // 2. RGB Split / Chromatic Aberration
                float offset = strength * 2.0;
                vec4 color = original;

                // Offset red and blue channels slightly
                color.r = original.r + sin(time + yPos * 0.1) * offset * 0.1;
                color.b = original.b - cos(time + yPos * 0.1) * offset * 0.1;

                // 3. Cyan/Blue hologram tint
                vec3 hologramTint = vec3(0.3, 0.8, 1.0); // Cyan-blue color
                color.rgb = mix(original.rgb, original.rgb * hologramTint, strength * 0.6);

                // 4. Add scanline brightness variation
                float scanlineEffect = scanline * 0.4 * strength;
                color.rgb += vec3(scanlineEffect * 0.3, scanlineEffect * 0.6, scanlineEffect * 1.0);

                // 5. Flickering / Glitching transparency
                float flicker = sin(time * 30.0 + yPos * 0.5) * 0.5 + 0.5;
                flicker = pow(flicker, 5.0); // Make it more sporadic
                float alphaVariation = 1.0 - (flicker * 0.15 * strength);

                // 6. Edge glow effect
                float edgeGlow = abs(sin(yPos * 0.15 + time * 5.0));
                color.rgb += vec3(0.0, 0.3, 0.5) * edgeGlow * strength * 0.3;

                return vec4(color.rgb, original.a * alphaVariation);
            }
        """
        return CIColorKernel(source: kernelString)!
    }()

    override init() {
        super.init()
        name = "hologram"
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        name = "hologram"
    }

    static func register() {
        CIFilter.registerName("HologramFilter", constructor: HologramFilterConstructor(), classAttributes: [
            kCIAttributeFilterCategories: ["CICategoryStylize", "CICategoryVideo", "CICategoryStillImage"]
        ])
    }

    override func setDefaults() {
        inputTime = 0.0
        inputStrength = 1.0
    }

    override var inputKeys: [String] {
        return ["inputImage", "inputTime", "inputStrength"]
    }
    
    // Ensure we support copying for the animation system
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = HologramFilter()
        copy.inputTime = inputTime
        copy.inputStrength = inputStrength
        copy.name = name
        return copy
    }

    override var outputImage: CIImage? {
        guard let inputImage = inputImage else { return nil }
        
        // Debug: Red fallback if kernel fails? No, kernel force unwrap prevents that.
        // If we are here, kernel exists.
        
        let time = NSNumber(value: Float(inputTime))
        let strength = NSNumber(value: Float(inputStrength))
        
        return HologramFilter.kernel.apply(extent: inputImage.extent,
                                           arguments: [inputImage, time, strength])
    }
}

class HologramFilterConstructor: NSObject, CIFilterConstructor {
    func filter(withName name: String) -> CIFilter? {
        if name == "HologramFilter" {
            return HologramFilter()
        }
        return nil
    }
}
