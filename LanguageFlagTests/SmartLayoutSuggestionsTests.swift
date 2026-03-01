import Testing
import Foundation
@testable import LanguageFlag

/// Test suite for Smart Layout Suggestions functionality
@Suite("Smart Layout Suggestions Tests")
struct SmartLayoutSuggestionsTests {
    
    // MARK: - App Preference Tests
    
    @Suite("App Layout Preferences")
    struct AppPreferenceTests {
        
        @Test("Record usage creates new app preference")
        func testRecordUsageCreatesPreference() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            suggestions.recordUsage(layout: "US", app: "Xcode")
            
            let preferences = suggestions.getAppPreferences()
            #expect(preferences.count == 1, "Should have one app preference")
            #expect(preferences.first?.appName == "Xcode", "App name should be Xcode")
        }
        
        @Test("Record multiple usages increments count")
        func testMultipleUsagesIncrement() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            // Record same layout multiple times
            suggestions.recordUsage(layout: "US", app: "Xcode")
            suggestions.recordUsage(layout: "US", app: "Xcode")
            suggestions.recordUsage(layout: "US", app: "Xcode")
            
            let preferences = suggestions.getAppPreferences()
            let xcodePref = preferences.first { $0.appName == "Xcode" }
            
            #expect(xcodePref?.layoutPreferences["US"] == 3, "US layout should have 3 uses")
        }
        
        @Test("Record different layouts for same app")
        func testMultipleLayoutsForApp() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            suggestions.recordUsage(layout: "US", app: "Xcode")
            suggestions.recordUsage(layout: "French", app: "Xcode")
            suggestions.recordUsage(layout: "US", app: "Xcode")
            
            let preferences = suggestions.getAppPreferences()
            let xcodePref = preferences.first { $0.appName == "Xcode" }
            
            #expect(xcodePref?.layoutPreferences.count == 2, "Should have 2 layouts")
            #expect(xcodePref?.layoutPreferences["US"] == 2, "US should have 2 uses")
            #expect(xcodePref?.layoutPreferences["French"] == 1, "French should have 1 use")
        }
        
        @Test("Last used layout is tracked")
        func testLastUsedLayout() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            suggestions.recordUsage(layout: "US", app: "Xcode")
            suggestions.recordUsage(layout: "French", app: "Xcode")
            
            let preferences = suggestions.getAppPreferences()
            let xcodePref = preferences.first { $0.appName == "Xcode" }
            
            #expect(xcodePref?.lastUsedLayout == "French", "Last used should be French")
        }
    }
    
    // MARK: - Confidence Score Tests
    
    @Suite("Confidence Score Calculation")
    struct ConfidenceScoreTests {
        
        @Test("Confidence score with single layout is 100%")
        func testSingleLayoutConfidence() async throws {
            let preference = AppLayoutPreference(
                appName: "Xcode",
                layoutPreferences: ["US": 10],
                lastUsedLayout: "US"
            )
            
            #expect(preference.confidenceScore == 1.0, "Single layout should have 100% confidence")
        }
        
        @Test("Confidence score with dominant layout")
        func testDominantLayoutConfidence() async throws {
            let preference = AppLayoutPreference(
                appName: "Xcode",
                layoutPreferences: ["US": 9, "French": 1],
                lastUsedLayout: "US"
            )
            
            #expect(preference.confidenceScore == 0.9, "Should be 90% confidence (9/10)")
        }
        
        @Test("Confidence score with equal usage")
        func testEqualUsageConfidence() async throws {
            let preference = AppLayoutPreference(
                appName: "Xcode",
                layoutPreferences: ["US": 5, "French": 5],
                lastUsedLayout: "US"
            )
            
            #expect(preference.confidenceScore == 0.5, "Should be 50% confidence with equal usage")
        }
        
        @Test("Empty preferences returns zero confidence")
        func testEmptyConfidence() async throws {
            let preference = AppLayoutPreference(
                appName: "Xcode",
                layoutPreferences: [:],
                lastUsedLayout: nil
            )
            
            #expect(preference.confidenceScore == 0.0, "Empty preferences should have 0% confidence")
        }
    }
    
    // MARK: - Suggestion Logic Tests
    
    @Suite("Layout Suggestions")
    struct SuggestionLogicTests {
        
        @Test("Get suggestion returns nil with insufficient data")
        func testInsufficientData() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            // Only record once (minimum is 3)
            suggestions.recordUsage(layout: "US", app: "Xcode")
            
            let suggestion = suggestions.getSuggestion(for: "Xcode")
            #expect(suggestion == nil, "Should return nil with insufficient usage data")
        }
        
        @Test("Get suggestion with sufficient data")
        func testSufficientData() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            // Record minimum required times (3)
            suggestions.recordUsage(layout: "US", app: "Xcode")
            suggestions.recordUsage(layout: "US", app: "Xcode")
            suggestions.recordUsage(layout: "US", app: "Xcode")
            
            let suggestion = suggestions.getSuggestion(for: "Xcode")
            #expect(suggestion == "US", "Should suggest US layout")
        }
        
        @Test("Low confidence app preferences are correctly identified")
        func testLowConfidenceDetection() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            // Create low confidence scenario: 55% confidence
            for _ in 0..<5 { suggestions.recordUsage(layout: "US", app: "Xcode") }
            for _ in 0..<4 { suggestions.recordUsage(layout: "French", app: "Xcode") }
            
            // Verify that the confidence score is correctly calculated as < 60%
            let preferences = suggestions.getAppPreferences()
            let xcodePref = preferences.first { $0.appName == "Xcode" }
            
            #expect(xcodePref?.confidenceScore == 5.0/9.0, "Confidence should be 55.6%")
            #expect(xcodePref?.confidenceScore ?? 1.0 < 0.6, "Confidence should be below 60% threshold")
        }
        
        @Test("High confidence app preferences return suggestions")
        func testHighConfidenceSuggestion() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            // Create high confidence scenario: 70% confidence
            for _ in 0..<7 { suggestions.recordUsage(layout: "US", app: "Xcode") }
            for _ in 0..<3 { suggestions.recordUsage(layout: "French", app: "Xcode") }
            
            // Verify high confidence is detected
            let preferences = suggestions.getAppPreferences()
            let xcodePref = preferences.first { $0.appName == "Xcode" }
            
            #expect(xcodePref?.confidenceScore == 0.7, "Confidence should be 70%")
            #expect(xcodePref?.confidenceScore ?? 0.0 >= 0.6, "Confidence should meet threshold")
            
            // With high confidence, should return a suggestion
            let suggestion = suggestions.getSuggestion(for: "Xcode")
            #expect(suggestion == "US", "Should suggest US with 70% confidence")
        }
        
        @Test("Get suggestion with exactly 60% confidence")
        func testExactlyMinimumConfidence() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            // Create exactly 60% confidence scenario
            // US: 6 times (60%), French: 4 times (40%)
            for _ in 0..<6 { suggestions.recordUsage(layout: "US", app: "Xcode") }
            for _ in 0..<4 { suggestions.recordUsage(layout: "French", app: "Xcode") }
            
            let suggestion = suggestions.getSuggestion(for: "Xcode")
            #expect(suggestion == "US", "Should suggest with exactly 60% confidence")
        }
        
        @Test("Get suggestion for unknown app returns nil")
        func testUnknownApp() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            suggestions.recordUsage(layout: "US", app: "Xcode")
            
            let suggestion = suggestions.getSuggestion(for: "Safari")
            #expect(suggestion == nil, "Should return nil for unknown app")
        }
        
        @Test("Preferred layout returns most used")
        func testPreferredLayout() async throws {
            let preference = AppLayoutPreference(
                appName: "Xcode",
                layoutPreferences: ["US": 10, "French": 3, "German": 1],
                lastUsedLayout: "German"
            )
            
            #expect(preference.preferredLayout == "US", "Preferred should be most used")
        }
    }
    
    // MARK: - Enable/Disable Tests
    
    @Suite("Smart Suggestions Toggle")
    struct EnableDisableTests {
        
        @Test("Smart suggestions enabled by default")
        func testEnabledByDefault() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            #expect(suggestions.isEnabled == true, "Should be enabled by default")
        }
        
        @Test("Disabled suggestions don't record usage")
        func testDisabledRecording() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            suggestions.isEnabled = false
            suggestions.recordUsage(layout: "US", app: "Xcode")
            
            let preferences = suggestions.getAppPreferences()
            #expect(preferences.isEmpty, "Should not record when disabled")
        }
        
        @Test("Disabled suggestions don't return suggestions")
        func testDisabledSuggestions() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            // Record data while enabled
            suggestions.recordUsage(layout: "US", app: "Xcode")
            suggestions.recordUsage(layout: "US", app: "Xcode")
            suggestions.recordUsage(layout: "US", app: "Xcode")
            
            // Disable
            suggestions.isEnabled = false
            
            let suggestion = suggestions.getSuggestion(for: "Xcode")
            #expect(suggestion == nil, "Should not return suggestions when disabled")
        }
    }
    
    // MARK: - Data Management Tests
    
    @Suite("Data Persistence")
    struct DataPersistenceTests {
        
        @Test("Clear all data removes preferences")
        func testClearAllData() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            // Add some data
            suggestions.recordUsage(layout: "US", app: "Xcode")
            suggestions.recordUsage(layout: "French", app: "Safari")
            
            // Verify data exists
            var preferences = suggestions.getAppPreferences()
            #expect(preferences.count == 2, "Should have 2 app preferences")
            
            // Clear
            suggestions.clearAllData()
            
            // Verify data is gone
            preferences = suggestions.getAppPreferences()
            #expect(preferences.isEmpty, "Should have no preferences after clearing")
        }
        
        @Test("Preferences sorted by confidence score")
        func testPreferencesSorting() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            // Create different confidence levels
            // Xcode: 90% confidence (9/10)
            for _ in 0..<9 { suggestions.recordUsage(layout: "US", app: "Xcode") }
            suggestions.recordUsage(layout: "French", app: "Xcode")
            
            // Safari: 75% confidence (3/4)
            for _ in 0..<3 { suggestions.recordUsage(layout: "French", app: "Safari") }
            suggestions.recordUsage(layout: "German", app: "Safari")
            
            let preferences = suggestions.getAppPreferences()
            
            #expect(preferences[0].appName == "Xcode", "Xcode should be first (highest confidence)")
            #expect(preferences[1].appName == "Safari", "Safari should be second")
        }
    }
    
    // MARK: - Multiple Apps Tests
    
    @Suite("Multiple Applications")
    struct MultipleAppsTests {
        
        @Test("Track multiple apps independently")
        func testMultipleApps() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            suggestions.recordUsage(layout: "US", app: "Xcode")
            suggestions.recordUsage(layout: "French", app: "Safari")
            suggestions.recordUsage(layout: "German", app: "Terminal")
            
            let preferences = suggestions.getAppPreferences()
            #expect(preferences.count == 3, "Should have 3 app preferences")
        }
        
        @Test("Each app has independent suggestions")
        func testIndependentSuggestions() async throws {
            let mockDefaults = MockUserDefaults()
            let suggestions = SmartLayoutSuggestions(defaults: mockDefaults)
            
            // Xcode uses US
            for _ in 0..<5 { suggestions.recordUsage(layout: "US", app: "Xcode") }
            
            // Safari uses French
            for _ in 0..<5 { suggestions.recordUsage(layout: "French", app: "Safari") }
            
            let xcodeSuggestion = suggestions.getSuggestion(for: "Xcode")
            let safariSuggestion = suggestions.getSuggestion(for: "Safari")
            
            #expect(xcodeSuggestion == "US", "Xcode should suggest US")
            #expect(safariSuggestion == "French", "Safari should suggest French")
        }
    }
}
