//
//  UserPreferences.swift
//  LanguageFlag
//
//  Created by Claude on 01/01/2026.
//

import Foundation

extension Notification.Name {

    static let preferencesPreviewRequested = Notification.Name("preferencesPreviewRequested")
}

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

    var description: String {
        rawValue
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

    private let defaults = UserDefaults.standard

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
    }

    // MARK: - Published Properties
    @Published var displayDuration: Double {
        didSet {
            defaults.set(displayDuration, forKey: Keys.displayDuration)
            NotificationCenter.default.post(name: .preferencesPreviewRequested, object: nil)
        }
    }

    @Published var displayPosition: DisplayPosition {
        didSet {
            if let encoded = try? JSONEncoder().encode(displayPosition) {
                defaults.set(encoded, forKey: Keys.displayPosition)
            }
            NotificationCenter.default.post(name: .preferencesPreviewRequested, object: nil)
        }
    }

    @Published var windowSize: WindowSize {
        didSet {
            if let encoded = try? JSONEncoder().encode(windowSize) {
                defaults.set(encoded, forKey: Keys.windowSize)
            }
            NotificationCenter.default.post(name: .preferencesPreviewRequested, object: nil)
        }
    }

    @Published var opacity: Double {
        didSet {
            defaults.set(opacity, forKey: Keys.opacity)
            NotificationCenter.default.post(name: .preferencesPreviewRequested, object: nil)
        }
    }

    @Published var animationStyle: AnimationStyle {
        didSet {
            if let encoded = try? JSONEncoder().encode(animationStyle) {
                defaults.set(encoded, forKey: Keys.animationStyle)
            }
            NotificationCenter.default.post(name: .preferencesPreviewRequested, object: nil)
        }
    }

    @Published var animationDuration: Double {
        didSet {
            defaults.set(animationDuration, forKey: Keys.animationDuration)
            NotificationCenter.default.post(name: .preferencesPreviewRequested, object: nil)
        }
    }

    @Published var showShortcuts: Bool {
        didSet { defaults.set(showShortcuts, forKey: Keys.showShortcuts) }
    }

    @Published var showInMenuBar: Bool {
        didSet { defaults.set(showInMenuBar, forKey: Keys.showInMenuBar) }
    }

    // MARK: - Initialization
    private init() {
        // Load saved values or use defaults
        self.displayDuration = defaults.object(forKey: Keys.displayDuration) as? Double ?? 1.0
        self.opacity = defaults.object(forKey: Keys.opacity) as? Double ?? 0.95
        self.animationDuration = defaults.object(forKey: Keys.animationDuration) as? Double ?? 0.3
        self.showShortcuts = defaults.object(forKey: Keys.showShortcuts) as? Bool ?? false
        self.showInMenuBar = defaults.object(forKey: Keys.showInMenuBar) as? Bool ?? false

        // Decode complex types
        if let data = defaults.data(forKey: Keys.displayPosition),
           let decoded = try? JSONDecoder().decode(DisplayPosition.self, from: data) {
            self.displayPosition = decoded
        } else {
            self.displayPosition = .bottomCenter
        }

        if let data = defaults.data(forKey: Keys.windowSize),
           let decoded = try? JSONDecoder().decode(WindowSize.self, from: data) {
            self.windowSize = decoded
        } else {
            self.windowSize = .medium
        }

        if let data = defaults.data(forKey: Keys.animationStyle),
           let decoded = try? JSONDecoder().decode(AnimationStyle.self, from: data) {
            self.animationStyle = decoded
        } else {
            self.animationStyle = .fade
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
    }
}
