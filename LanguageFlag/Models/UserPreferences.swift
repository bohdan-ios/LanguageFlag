import Foundation

enum DisplayPosition: String, Codable, CaseIterable {

    case topLeft = "Top Left"
    case topCenter = "Top Center"
    case topRight = "Top Right"
    case centerLeft = "Center Left"
    case center = "Center"
    case centerRight = "Center Right"
    case bottomLeft = "Bottom Left"
    case bottomCenter = "Bottom Center"
    case bottomRight = "Bottom Right"

    var description: String {
        rawValue
    }
}

enum WindowSize: String, Codable, CaseIterable {

    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"

    var dimensions: (width: CGFloat, height: CGFloat) {
        switch self {
        case .small:
            return (200, 124)
        case .medium:
            return (250, 155)
        case .large:
            return (300, 186)
        case .extraLarge:
            return (350, 217)
        }
    }

    var fontSizes: (title: CGFloat, label: CGFloat) {
        switch self {
        case .small:
            return (17, 13)
        case .medium:
            return (21, 16)
        case .large:
            return (25, 19)
        case .extraLarge:
            return (29, 22)
        }
    }

    var description: String {
        rawValue
    }
}

enum SoundEffect: String, Codable, CaseIterable {

    case blip = "sound-blip"
    case click = "sound-click"
    case click2 = "sound-click-2"
    case ding = "sound-ding"
    case notify = "sound-notify"
    case notify2 = "sound-notify-2"
    case notify3 = "sound-notify-3"
    case pop = "sound-pop"
    case `switch` = "sound-switch"
    case switch2 = "sound-switch-2"

    var displayName: String {
        switch self {
        case .blip: return "Blip"
        case .click: return "Click"
        case .click2: return "Click 2"
        case .ding: return "Ding"
        case .notify: return "Notification"
        case .notify2: return "Notification 2"
        case .notify3: return "Notification 3"
        case .pop: return "Pop"
        case .switch: return "Switch"
        case .switch2: return "Switch 2"
        }
    }
}

enum AnimationStyle: String, Codable, CaseIterable {

    case fade = "Fade"
    case slide = "Slide"
    case scale = "Scale"
    case pixelate = "Pixelate"
    case blur = "Blur"
    case flip = "Flip"
    case bounce = "Bounce"
    case rotate = "Rotate"
    case swing = "Swing"
    case elastic = "Elastic"
    case hologram = "Hologram"
    case energyPortal = "Energy Portal"
    case digitalMaterialize = "Digital Materialize"
    case liquidRipple = "Liquid Ripple"
    case inkDiffusion = "Ink Diffusion"
    case vhsGlitch = "VHS Glitch"

    var description: String {
        rawValue
    }
}

final class UserPreferences: ObservableObject {

    static let shared = UserPreferences()

    private let defaults: UserDefaults

    // MARK: - Keys
    private enum Keys {

        static let displayDuration = "displayDuration"
        static let displayPosition = "displayPosition"
        static let windowSize = "windowSize"
        static let opacity = "opacity"
        static let animationStyle = "animationStyle"
        static let animationDuration = "animationDuration"
        static let showShortcuts = "showShortcuts"
        static let showInMenuBar = "showInMenuBar"
        static let resetAnimationOnChange = "resetAnimationOnChange"
        static let showCapsLockIndicator = "showCapsLockIndicator"
        static let bypassClick = "bypassClick"
        static let showDockIndicator = "showDockIndicator"
        static let playSoundOnSwitch = "playSoundOnSwitch"
        static let selectedSoundEffect = "selectedSoundEffect"
        static let soundVolume = "soundVolume"
    }

    // MARK: - Published Properties
    @Published var displayDuration: Double {
        didSet { defaults.set(displayDuration, forKey: Keys.displayDuration) }
    }

    @Published var displayPosition: DisplayPosition {
        didSet {
            if let encoded = try? JSONEncoder().encode(displayPosition) {
                defaults.set(encoded, forKey: Keys.displayPosition)
            }
        }
    }

    @Published var windowSize: WindowSize {
        didSet {
            if let encoded = try? JSONEncoder().encode(windowSize) {
                defaults.set(encoded, forKey: Keys.windowSize)
            }
        }
    }

    @Published var opacity: Double {
        didSet { defaults.set(opacity, forKey: Keys.opacity) }
    }

    @Published var animationStyle: AnimationStyle {
        didSet {
            if let encoded = try? JSONEncoder().encode(animationStyle) {
                defaults.set(encoded, forKey: Keys.animationStyle)
            }
        }
    }

    @Published var animationDuration: Double {
        didSet { defaults.set(animationDuration, forKey: Keys.animationDuration) }
    }

    @Published var showShortcuts: Bool {
        didSet { defaults.set(showShortcuts, forKey: Keys.showShortcuts) }
    }

    @Published var showInMenuBar: Bool {
        didSet { defaults.set(showInMenuBar, forKey: Keys.showInMenuBar) }
    }

    @Published var resetAnimationOnChange: Bool {
        didSet { defaults.set(resetAnimationOnChange, forKey: Keys.resetAnimationOnChange) }
    }

    @Published var showCapsLockIndicator: Bool {
        didSet { defaults.set(showCapsLockIndicator, forKey: Keys.showCapsLockIndicator) }
    }
    
    @Published var bypassClick: Bool {
        didSet { defaults.set(bypassClick, forKey: Keys.bypassClick) }
    }

    @Published var showDockIndicator: Bool {
        didSet { defaults.set(showDockIndicator, forKey: Keys.showDockIndicator) }
    }

    @Published var playSoundOnSwitch: Bool {
        didSet { defaults.set(playSoundOnSwitch, forKey: Keys.playSoundOnSwitch) }
    }

    @Published var selectedSoundEffect: SoundEffect {
        didSet {
            if let encoded = try? JSONEncoder().encode(selectedSoundEffect) {
                defaults.set(encoded, forKey: Keys.selectedSoundEffect)
            }
        }
    }

    @Published var soundVolume: Double {
        didSet { defaults.set(soundVolume, forKey: Keys.soundVolume) }
    }

    // MARK: - Initialization
    private init() {
        self.defaults = .standard
        self.displayDuration = 1.0
        self.opacity = 0.95
        self.animationDuration = 0.3
        self.showShortcuts = false
        self.showInMenuBar = false
        self.resetAnimationOnChange = true
        self.showCapsLockIndicator = true
        self.bypassClick = true
        self.showDockIndicator = false
        self.playSoundOnSwitch = false
        self.displayPosition = .bottomCenter
        self.windowSize = .medium
        self.animationStyle = .fade
        self.selectedSoundEffect = .click
        self.soundVolume = 0.7

        loadSavedPreferences()
    }

    // Initializer for testing with dependency injection
    init(defaults: UserDefaults) {
        self.defaults = defaults
        self.displayDuration = 1.0
        self.opacity = 0.95
        self.animationDuration = 0.3
        self.showShortcuts = false
        self.showInMenuBar = false
        self.resetAnimationOnChange = true
        self.showCapsLockIndicator = true
        self.bypassClick = true
        self.showDockIndicator = false
        self.playSoundOnSwitch = false
        self.displayPosition = .bottomCenter
        self.windowSize = .medium
        self.animationStyle = .fade
        self.selectedSoundEffect = .click
        self.soundVolume = 0.7

        loadSavedPreferences()
    }
    
    private func loadSavedPreferences() {
        // Load saved values or use defaults
        self.displayDuration = defaults.object(forKey: Keys.displayDuration) as? Double ?? 1.0
        self.opacity = defaults.object(forKey: Keys.opacity) as? Double ?? 0.95
        self.animationDuration = defaults.object(forKey: Keys.animationDuration) as? Double ?? 0.3
        self.showShortcuts = defaults.object(forKey: Keys.showShortcuts) as? Bool ?? false
        self.showInMenuBar = defaults.object(forKey: Keys.showInMenuBar) as? Bool ?? false
        self.resetAnimationOnChange = defaults.object(forKey: Keys.resetAnimationOnChange) as? Bool ?? true
        self.showCapsLockIndicator = defaults.object(forKey: Keys.showCapsLockIndicator) as? Bool ?? true
        self.bypassClick = defaults.object(forKey: Keys.bypassClick) as? Bool ?? true
        self.showDockIndicator = defaults.object(forKey: Keys.showDockIndicator) as? Bool ?? false
        self.playSoundOnSwitch = defaults.object(forKey: Keys.playSoundOnSwitch) as? Bool ?? false
        self.soundVolume = defaults.object(forKey: Keys.soundVolume) as? Double ?? 0.7

        // Decode complex types
        if
            let data = defaults.data(forKey: Keys.displayPosition),
            let decoded = try? JSONDecoder().decode(DisplayPosition.self, from: data)
        {
            self.displayPosition = decoded
        } else {
            self.displayPosition = .bottomCenter
        }

        if
            let data = defaults.data(forKey: Keys.windowSize),
            let decoded = try? JSONDecoder().decode(WindowSize.self, from: data)
        {
            self.windowSize = decoded
        } else {
            self.windowSize = .medium
        }

        if
            let data = defaults.data(forKey: Keys.animationStyle),
            let decoded = try? JSONDecoder().decode(AnimationStyle.self, from: data)
        {
            self.animationStyle = decoded
        } else {
            self.animationStyle = .fade
        }

        if
            let data = defaults.data(forKey: Keys.selectedSoundEffect),
            let decoded = try? JSONDecoder().decode(SoundEffect.self, from: data)
        {
            self.selectedSoundEffect = decoded
        } else {
            self.selectedSoundEffect = .click
        }
    }

    func resetToDefaults() {
        displayDuration = 1.0
        displayPosition = .bottomCenter
        windowSize = .medium
        opacity = 0.95
        animationStyle = .fade
        animationDuration = 0.3
        showShortcuts = false
        showInMenuBar = false
        resetAnimationOnChange = true
        showCapsLockIndicator = true
        bypassClick = true
        showDockIndicator = false
        playSoundOnSwitch = false
        selectedSoundEffect = .click
        soundVolume = 0.7
    }
}
