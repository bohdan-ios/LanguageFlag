import Testing
import Foundation
import Combine
@testable import LanguageFlag

/// Test suite for User Preferences functionality
@Suite("User Preferences Tests")
struct UserPreferencesTests {
    
    // MARK: - Default Values Tests
    
    @Suite("Default Values")
    struct DefaultValuesTests {
        
        @Test("Default values are set correctly")
        func testDefaultValues() async throws {
            let mockDefaults = MockUserDefaults()
            let prefs = UserPreferences(defaults: mockDefaults)
            
            #expect(prefs.displayDuration == 1.0, "Default display duration should be 1.0")
            #expect(prefs.opacity == 0.95, "Default opacity should be 0.95")
            #expect(prefs.animationDuration == 0.3, "Default animation duration should be 0.3")
            #expect(prefs.showShortcuts == false, "showShortcuts should default to false")
            #expect(prefs.showInMenuBar == false, "showInMenuBar should default to false")
            #expect(prefs.resetAnimationOnChange == true, "resetAnimationOnChange should default to true")
            #expect(prefs.displayPosition == .bottomCenter, "Default position should be bottom center")
            #expect(prefs.windowSize == .medium, "Default window size should be medium")
            #expect(prefs.animationStyle == .fade, "Default animation style should be fade")
        }
    }
    
    // MARK: - Persistence Tests
    
    @Suite("Data Persistence")
    struct PersistenceTests {
        
        @Test("Display duration persists")
        func testDisplayDurationPersistence() async throws {
            let mockDefaults = MockUserDefaults()
            let prefs = UserPreferences(defaults: mockDefaults)
            
            prefs.displayDuration = 2.5
            
            // Create new instance - should load saved value
            let newPrefs = UserPreferences(defaults: mockDefaults)
            #expect(newPrefs.displayDuration == 2.5, "Display duration should persist")
        }
        
        @Test("Opacity persists")
        func testOpacityPersistence() async throws {
            let mockDefaults = MockUserDefaults()
            let prefs = UserPreferences(defaults: mockDefaults)
            
            prefs.opacity = 0.75
            
            let newPrefs = UserPreferences(defaults: mockDefaults)
            #expect(newPrefs.opacity == 0.75, "Opacity should persist")
        }
        
        @Test("Animation duration persists")
        func testAnimationDurationPersistence() async throws {
            let mockDefaults = MockUserDefaults()
            let prefs = UserPreferences(defaults: mockDefaults)
            
            prefs.animationDuration = 0.5
            
            let newPrefs = UserPreferences(defaults: mockDefaults)
            #expect(newPrefs.animationDuration == 0.5, "Animation duration should persist")
        }
        
        @Test("Boolean preferences persist")
        func testBooleanPersistence() async throws {
            let mockDefaults = MockUserDefaults()
            let prefs = UserPreferences(defaults: mockDefaults)
            
            prefs.showShortcuts = true
            prefs.showInMenuBar = true
            prefs.resetAnimationOnChange = false
            
            let newPrefs = UserPreferences(defaults: mockDefaults)
            #expect(newPrefs.showShortcuts == true)
            #expect(newPrefs.showInMenuBar == true)
            #expect(newPrefs.resetAnimationOnChange == false)
        }
        
        @Test("Display position persists")
        func testDisplayPositionPersistence() async throws {
            let mockDefaults = MockUserDefaults()
            let prefs = UserPreferences(defaults: mockDefaults)
            
            prefs.displayPosition = .topRight
            
            let newPrefs = UserPreferences(defaults: mockDefaults)
            #expect(newPrefs.displayPosition == .topRight, "Display position should persist")
        }
        
        @Test("Window size persists")
        func testWindowSizePersistence() async throws {
            let mockDefaults = MockUserDefaults()
            let prefs = UserPreferences(defaults: mockDefaults)
            
            prefs.windowSize = .large
            
            let newPrefs = UserPreferences(defaults: mockDefaults)
            #expect(newPrefs.windowSize == .large, "Window size should persist")
        }
        
        @Test("Animation style persists")
        func testAnimationStylePersistence() async throws {
            let mockDefaults = MockUserDefaults()
            let prefs = UserPreferences(defaults: mockDefaults)
            
            prefs.animationStyle = .bounce
            
            let newPrefs = UserPreferences(defaults: mockDefaults)
            #expect(newPrefs.animationStyle == .bounce, "Animation style should persist")
        }
    }
    
    // MARK: - Reset to Defaults Tests
    
    @Suite("Reset Functionality")
    struct ResetTests {
        
        @Test("Reset to defaults restores all values")
        func testResetToDefaults() async throws {
            let mockDefaults = MockUserDefaults()
            let prefs = UserPreferences(defaults: mockDefaults)
            
            // Change all values
            prefs.displayDuration = 3.0
            prefs.opacity = 0.5
            prefs.animationDuration = 1.0
            prefs.showShortcuts = true
            prefs.showInMenuBar = true
            prefs.resetAnimationOnChange = false
            prefs.displayPosition = .topLeft
            prefs.windowSize = .extraLarge
            prefs.animationStyle = .hologram
            
            // Reset
            prefs.resetToDefaults()
            
            // Verify all values restored
            #expect(prefs.displayDuration == 1.0)
            #expect(prefs.opacity == 0.95)
            #expect(prefs.animationDuration == 0.3)
            #expect(prefs.showShortcuts == false)
            #expect(prefs.showInMenuBar == false)
            #expect(prefs.resetAnimationOnChange == true)
            #expect(prefs.displayPosition == .bottomCenter)
            #expect(prefs.windowSize == .medium)
            #expect(prefs.animationStyle == .fade)
        }
    }
    
    // MARK: - Enum Value Tests
    
    @Suite("Display Position")
    struct DisplayPositionTests {
        
        @Test("All display positions are available")
        func testAllPositions() async throws {
            let allCases = DisplayPosition.allCases
            #expect(allCases.count == 9, "Should have 9 display positions")
        }
        
        @Test("Display position descriptions are correct")
        func testPositionDescriptions() async throws {
            #expect(DisplayPosition.topLeft.description == "Top Left")
            #expect(DisplayPosition.center.description == "Center")
            #expect(DisplayPosition.bottomRight.description == "Bottom Right")
        }
    }
    
    @Suite("Window Size")
    struct WindowSizeTests {
        
        @Test("Window size dimensions are correct")
        func testWindowDimensions() async throws {
            #expect(WindowSize.small.dimensions.width == 200)
            #expect(WindowSize.small.dimensions.height == 124)
            
            #expect(WindowSize.medium.dimensions.width == 250)
            #expect(WindowSize.large.dimensions.width == 300)
            #expect(WindowSize.extraLarge.dimensions.width == 350)
        }
        
        @Test("Window size font sizes scale correctly")
        func testFontSizes() async throws {
            // Small has smallest fonts
            #expect(WindowSize.small.fontSizes.title == 17)
            #expect(WindowSize.small.fontSizes.label == 13)
            
            // Extra large has largest fonts
            #expect(WindowSize.extraLarge.fontSizes.title == 29)
            #expect(WindowSize.extraLarge.fontSizes.label == 22)
        }
        
        @Test("Font sizes increase with window size")
        func testFontSizesIncrease() async throws {
            let sizes = WindowSize.allCases
            
            for i in 0..<sizes.count - 1 {
                let current = sizes[i].fontSizes.title
                let next = sizes[i + 1].fontSizes.title
                #expect(next > current, "Title fonts should increase with size")
            }
        }
    }
    
    @Suite("Animation Style")
    struct AnimationStyleTests {
        
        @Test("All animation styles are available")
        func testAllAnimationStyles() async throws {
            let allCases = AnimationStyle.allCases
            #expect(allCases.count == 16, "Should have 16 animation styles")
        }
        
        @Test("Animation style descriptions match raw values")
        func testAnimationDescriptions() async throws {
            #expect(AnimationStyle.fade.description == "Fade")
            #expect(AnimationStyle.bounce.description == "Bounce")
            #expect(AnimationStyle.hologram.description == "Hologram")
            #expect(AnimationStyle.vhsGlitch.description == "VHS Glitch")
        }
        
        @Test("All animation styles are unique")
        func testUniqueAnimationStyles() async throws {
            let allCases = AnimationStyle.allCases
            let descriptions = allCases.map { $0.description }
            let uniqueDescriptions = Set(descriptions)
            
            #expect(descriptions.count == uniqueDescriptions.count, "All animations should be unique")
        }
    }
    
    // MARK: - Value Validation Tests
    
    @Suite("Value Ranges")
    struct ValueRangeTests {
        
        @Test("Display duration accepts valid values")
        func testDisplayDurationRange() async throws {
            let mockDefaults = MockUserDefaults()
            let prefs = UserPreferences(defaults: mockDefaults)
            
            // Test various valid values
            for duration in [0.5, 1.0, 2.0, 5.0] {
                prefs.displayDuration = duration
                #expect(prefs.displayDuration == duration)
            }
        }
        
        @Test("Opacity accepts valid values")
        func testOpacityRange() async throws {
            let mockDefaults = MockUserDefaults()
            let prefs = UserPreferences(defaults: mockDefaults)
            
            // Test values between 0 and 1
            for opacity in [0.0, 0.25, 0.5, 0.75, 1.0] {
                prefs.opacity = opacity
                #expect(prefs.opacity == opacity)
            }
        }
        
        @Test("Animation duration accepts valid values")
        func testAnimationDurationRange() async throws {
            let mockDefaults = MockUserDefaults()
            let prefs = UserPreferences(defaults: mockDefaults)
            
            for duration in [0.1, 0.3, 0.5, 1.0] {
                prefs.animationDuration = duration
                #expect(prefs.animationDuration == duration)
            }
        }
    }
}
