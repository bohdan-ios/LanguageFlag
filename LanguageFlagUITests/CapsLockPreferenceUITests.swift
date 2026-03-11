import XCTest

/// UI tests for the Caps Lock preference toggle in the General pane.
///
/// Note: Simulating an actual Caps Lock key press in UI tests is not supported
/// by XCTest, so these tests cover the preference UI only — existence, toggling,
/// and state restoration.
final class CapsLockPreferenceUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        sleep(2)
        app.activate()
        sleep(1)
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tests

    /// Verifies the toggle exists in the General pane
    func testCapsLockToggleExists() throws {
        openPreferences()

        let toggle = capsLockToggle()
        XCTAssertTrue(toggle.waitForExistence(timeout: 3), "Caps Lock toggle should exist in General pane")
        XCTAssertTrue(toggle.isEnabled, "Caps Lock toggle should be enabled")
    }

    /// Verifies the toggle changes value when clicked
    func testCapsLockToggleChangesState() throws {
        openPreferences()

        let toggle = capsLockToggle()
        XCTAssertTrue(toggle.waitForExistence(timeout: 3))

        // macOS checkbox value is NSNumber (0 or 1), cast to Int
        let before = toggle.value as? Int
        XCTAssertNotNil(before, "Toggle value should be readable as Int")

        toggle.click()
        sleep(1)

        let after = toggle.value as? Int
        XCTAssertNotEqual(before, after, "Toggle value should change after clicking")
    }

    /// Verifies double-toggling restores the original state
    func testCapsLockToggleDoubleToggleRestores() throws {
        openPreferences()

        let toggle = capsLockToggle()
        XCTAssertTrue(toggle.waitForExistence(timeout: 3))

        let initialValue = toggle.value as? Int

        toggle.click()
        sleep(1)
        toggle.click()
        sleep(1)

        let restoredValue = toggle.value as? Int
        XCTAssertEqual(initialValue, restoredValue, "Toggle should be restored after two clicks")
    }

    /// Verifies the toggle is accessible by its label text
    func testCapsLockToggleLabelText() throws {
        openPreferences()

        // SwiftUI Toggle on macOS renders as a checkbox whose accessibility
        // label IS the toggle title — no separate staticText element exists.
        let toggle = capsLockToggle()
        XCTAssertTrue(toggle.waitForExistence(timeout: 3), "Checkbox with label 'Show indicator on Caps Lock change' should exist")
        XCTAssertEqual(toggle.label, "Show indicator on Caps Lock change")
    }

    // MARK: - Helpers

    private func capsLockToggle() -> XCUIElement {
        app.checkBoxes["Show indicator on Caps Lock change"]
    }

    private func openPreferences() {
        let statusItem = app.statusItems.firstMatch
        guard statusItem.waitForExistence(timeout: 3) else {
            XCTFail("Status bar item not found")
            return
        }
        statusItem.click()

        let prefsMenuItem = app.menuItems["Preferences..."]
        guard prefsMenuItem.waitForExistence(timeout: 3) else {
            XCTFail("Preferences menu item not found")
            return
        }
        prefsMenuItem.click()
        _ = app.windows["LanguageFlag Preferences"].waitForExistence(timeout: 10)

        // General tab should be selected by default; navigate there if needed
        let generalTab = app.tabs["General"]
        if generalTab.waitForExistence(timeout: 3) {
            generalTab.click()
        }
    }
}
