import Testing
import Foundation
@testable import LanguageFlag

@Suite("FeatureFlags Tests")
struct FeatureFlagsTests {

    // MARK: - Return Type

    @Test("isShortcutsEnabled returns a Bool")
    func testIsShortcutsEnabledReturnsBool() {
        let value = FeatureFlags.isShortcutsEnabled
        #expect(value == true || value == false)
    }

    @Test("isAnalyticsEnabled returns a Bool")
    func testIsAnalyticsEnabledReturnsBool() {
        let value = FeatureFlags.isAnalyticsEnabled
        #expect(value == true || value == false)
    }

    @Test("isGroupsEnabled returns a Bool")
    func testIsGroupsEnabledReturnsBool() {
        let value = FeatureFlags.isGroupsEnabled
        #expect(value == true || value == false)
    }

    // MARK: - PreferencePane Integration

    @Test("availableCases always includes general, appearance, about")
    func testAlwaysAvailablePanes() {
        let available = PreferencePane.availableCases
        #expect(available.contains(.general))
        #expect(available.contains(.appearance))
        #expect(available.contains(.about))
    }

    @Test("availableCases count is at least 3 (always-on panes)")
    func testMinimumAvailableCount() {
        #expect(PreferencePane.availableCases.count >= 3)
    }

    @Test("availableCases count does not exceed total case count")
    func testAvailableDoesNotExceedTotal() {
        #expect(PreferencePane.availableCases.count <= PreferencePane.allCases.count)
    }

    @Test("shortcuts pane availability matches flag")
    func testShortcutsPaneMatchesFlag() {
        let available = PreferencePane.availableCases.contains(.shortcuts)
        #expect(available == FeatureFlags.isShortcutsEnabled)
    }

    @Test("analytics pane availability matches flag")
    func testAnalyticsPaneMatchesFlag() {
        let available = PreferencePane.availableCases.contains(.analytics)
        #expect(available == FeatureFlags.isAnalyticsEnabled)
    }

    @Test("groups pane availability matches flag")
    func testGroupsPaneMatchesFlag() {
        let available = PreferencePane.availableCases.contains(.groups)
        #expect(available == FeatureFlags.isGroupsEnabled)
    }

    // MARK: - PreferencePane.isAvailable

    @Test("general pane is always available")
    func testGeneralAlwaysAvailable() {
        #expect(PreferencePane.general.isAvailable == true)
    }

    @Test("appearance pane is always available")
    func testAppearanceAlwaysAvailable() {
        #expect(PreferencePane.appearance.isAvailable == true)
    }

    @Test("about pane is always available")
    func testAboutAlwaysAvailable() {
        #expect(PreferencePane.about.isAvailable == true)
    }

    @Test("availableCases contains only panes where isAvailable is true")
    func testAvailableCasesConsistency() {
        for pane in PreferencePane.allCases {
            if pane.isAvailable {
                #expect(PreferencePane.availableCases.contains(pane))
            } else {
                #expect(!PreferencePane.availableCases.contains(pane))
            }
        }
    }

    // MARK: - PreferencePane Properties

    @Test("all panes have non-empty icon names")
    func testPaneIconsNonEmpty() {
        for pane in PreferencePane.allCases {
            #expect(!pane.icon.isEmpty, "Icon for \(pane.rawValue) should not be empty")
        }
    }

    @Test("all panes have non-empty raw values")
    func testPaneRawValuesNonEmpty() {
        for pane in PreferencePane.allCases {
            #expect(!pane.rawValue.isEmpty)
        }
    }

    @Test("pane id equals rawValue")
    func testPaneIdEqualsRawValue() {
        for pane in PreferencePane.allCases {
            #expect(pane.id == pane.rawValue)
        }
    }
}
