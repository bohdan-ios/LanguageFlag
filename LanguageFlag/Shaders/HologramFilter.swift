import CoreImage

class HologramFilter: CIFilter {

    // MARK: - Variables
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputTime: CGFloat = 0.0
    @objc dynamic var inputStrength: CGFloat = 1.0

    // MARK: - Statics
    static var kernel: CIKernel = {
        guard
            let url = Bundle.main.url(forResource: "default", withExtension: "metallib"),
            let data = try? Data(contentsOf: url),
            let kernel = try? CIKernel(functionName: "hologramKernel", fromMetalLibraryData: data)
        else {
            fatalError("Failed to load Metal kernel for hologram effect")
        }

        return kernel
    }()

    static func register() {
        CIFilter.registerName("HologramFilter",
                              constructor: HologramFilterConstructor(),
                              classAttributes: [
            kCIAttributeFilterCategories: [
                "CICategoryStylize",
                "CICategoryVideo",
                "CICategoryStillImage",
            ]
        ])
    }

    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        name = "hologram"
    }

    // MARK: - Overrides
    override init() {
        super.init()
        name = "hologram"
    }

    override func setDefaults() {
        inputTime = 0.0
        inputStrength = 1.0
    }

    override var inputKeys: [String] {
        ["inputImage", "inputTime", "inputStrength"]
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = HologramFilter()
        copy.inputTime = inputTime
        copy.inputStrength = inputStrength
        copy.name = name

        return copy
    }

    override var outputImage: CIImage? {
        guard let inputImage = inputImage else { return nil }
        
        let time = NSNumber(value: Float(inputTime))
        let strength = NSNumber(value: Float(inputStrength))
        
        return HologramFilter.kernel.apply(extent: inputImage.extent,
                                           roiCallback: { _, rect in rect },
                                           arguments: [inputImage, time, strength])
    }
}

// MARK: - HologramFilterConstructor
class HologramFilterConstructor: NSObject, CIFilterConstructor {

    func filter(withName name: String) -> CIFilter? {
        if name == "HologramFilter" {
            return HologramFilter()
        }

        return nil
    }
}
