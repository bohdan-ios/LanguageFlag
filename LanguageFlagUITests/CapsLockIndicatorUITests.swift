import XCTest
import CoreGraphics

/// UI tests that verify the language indicator window appears and hides
/// when Caps Lock is toggled on and off.
///
/// Prerequisites:
/// - "Show indicator on Caps Lock change" must be ON in General preferences.
/// - Caps Lock must start in the OFF state (the test enforces this).
///
/// Note: These tests post real CGEvents, so Caps Lock state on the system
/// will be temporarily changed. tearDown restores the original state.
final class CapsLockIndicatorUITests: XCTestCase {

    var app: XCUIApplication!
    private var capsLockWasOnAtStart = false

    override func setUpWithError() throws {
        continueAfterFailure = false

        // Record initial caps lock state so tearDown can restore it
        capsLockWasOnAtStart = CGEventSource
            .flagsState(.combinedSessionState)
            .contains(.maskAlphaShift)

        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        sleep(2)
        app.activate()
        sleep(1)

        // Ensure Caps Lock is OFF before each test
        if CGEventSource.flagsState(.combinedSessionState).contains(.maskAlphaShift) {
            holdCapsLock()
            sleep(1)
        }
    }

    override func tearDownWithError() throws {
        // Restore caps lock to the state it was in before the test suite ran
        let currentlyOn = CGEventSource
            .flagsState(.combinedSessionState)
            .contains(.maskAlphaShift)

        if currentlyOn != capsLockWasOnAtStart {
            holdCapsLock()
        }

        app = nil
    }

    // MARK: - Tests

    /// Enable Caps Lock indicator in settings, press Caps Lock ON, verify the window
    /// appears and the language label contains the caps lock character (⇪).
    func testCapsLockWindowShowsCorrectText() throws {
        try ensureCapsLockPreferenceEnabled()

        // Caps Lock is OFF — one press turns it ON
        holdCapsLock()

        let window = app.windows["LanguageIndicatorWindow"]
        XCTAssertTrue(
            window.waitForExistence(timeout: 3),
            "Language indicator window should appear when Caps Lock is turned on"
        )

        // When Caps Lock is ON the language label reads "⇪ <layout-name>".
        // Search from app root — statusBar-level windows restrict window.descendants traversal.
        // Check both .value (AXValue) and .label (AXTitle) since NSTextField label mode may use either.
        let nameLabel = app.descendants(matching: .any).matching(identifier: "languageNameLabel").firstMatch
        let bigLabel = app.descendants(matching: .any).matching(identifier: "bigLabel").firstMatch

        _ = nameLabel.waitForExistence(timeout: 3)
        _ = bigLabel.waitForExistence(timeout: 1)

        let nameLabelText = (nameLabel.value as? String) ?? nameLabel.label
        let bigLabelText = (bigLabel.value as? String) ?? bigLabel.label

        XCTAssertTrue(
            nameLabelText.contains("⇪") || bigLabelText.contains("⇪"),
            "Window should display the caps lock indicator character (⇪) in the language label"
        )

        // Wait for auto-hide
        let hideExpectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: window
        )
        wait(for: [hideExpectation], timeout: 8)
    }

    /// Press Caps Lock → window appears → auto-hides after display duration
    func testCapsLockShowsIndicatorWindow() throws {
        try ensureCapsLockPreferenceEnabled()

        // Caps Lock is OFF — press to turn ON
        holdCapsLock()

        let window = app.windows["LanguageIndicatorWindow"]
        XCTAssertTrue(
            window.waitForExistence(timeout: 3),
            "Language indicator window should appear when Caps Lock is turned on"
        )

        // Window should auto-hide after display duration (default 1s + animation ~0.5s)
        let hidePredicate = NSPredicate(format: "exists == false")
        let hideExpectation = XCTNSPredicateExpectation(predicate: hidePredicate, object: window)
        wait(for: [hideExpectation], timeout: 8)
    }

    /// Press Caps Lock ON → window shows → hides → press again OFF → window shows →
    /// hides → press again ON → window shows again
    func testCapsLockShowsHidesAndShowsAgain() throws {
        try ensureCapsLockPreferenceEnabled()

        let window = app.windows["LanguageIndicatorWindow"]

        // --- First press: Caps Lock ON ---
        holdCapsLock()
        XCTAssertTrue(
            window.waitForExistence(timeout: 3),
            "Window should appear on first Caps Lock ON"
        )

        // Wait for auto-hide
        let hide1 = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: window
        )
        wait(for: [hide1], timeout: 8)

        // --- Second press: Caps Lock OFF — window should appear (indicator shows on every change) ---
        holdCapsLock()
        XCTAssertTrue(
            window.waitForExistence(timeout: 3),
            "Window should appear when Caps Lock is turned off"
        )

        // Wait for auto-hide
        let hide2 = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: window
        )
        wait(for: [hide2], timeout: 8)

        // --- Third press: Caps Lock ON again — window must appear ---
        holdCapsLock()
        XCTAssertTrue(
            window.waitForExistence(timeout: 5),
            "Window should appear again on second Caps Lock ON"
        )

        // Wait for auto-hide
        let hide3 = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: window
        )
        wait(for: [hide3], timeout: 8)
    }

    /// When Caps Lock turns OFF the window should appear but WITHOUT the ⇪ character.
    func testCapsLockOffWindowHasNoCapsIndicator() throws {
        try ensureCapsLockPreferenceEnabled()

        let window = app.windows["LanguageIndicatorWindow"]

        // First press: Caps Lock ON → window with ⇪
        holdCapsLock()
        XCTAssertTrue(window.waitForExistence(timeout: 3), "Window should appear on Caps Lock ON")
        let hide1 = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: window)
        wait(for: [hide1], timeout: 8)

        // Second press: Caps Lock OFF → window without ⇪
        holdCapsLock()
        XCTAssertTrue(window.waitForExistence(timeout: 3), "Window should appear on Caps Lock OFF")

        let nameLabel = app.descendants(matching: .any).matching(identifier: "languageNameLabel").firstMatch
        let bigLabel = app.descendants(matching: .any).matching(identifier: "bigLabel").firstMatch
        _ = nameLabel.waitForExistence(timeout: 2)
        _ = bigLabel.waitForExistence(timeout: 1)
        let nameLabelText = (nameLabel.value as? String) ?? nameLabel.label
        let bigLabelText = (bigLabel.value as? String) ?? bigLabel.label
        XCTAssertFalse(nameLabelText.contains("⇪") || bigLabelText.contains("⇪"), "Window should NOT show ⇪ when Caps Lock is OFF")

        let hide2 = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: window)
        wait(for: [hide2], timeout: 8)
    }

    /// The window must always contain a non-empty language name label.
    func testWindowContainsNonEmptyLanguageName() throws {
        try ensureCapsLockPreferenceEnabled()

        holdCapsLock()

        let window = app.windows["LanguageIndicatorWindow"]
        XCTAssertTrue(window.waitForExistence(timeout: 3))

        // Search from app root — statusBar-level windows restrict window.descendants traversal.
        // Check both .value (AXValue) and .label (AXTitle) since NSTextField label mode may use either.
        let nameLabel = app.descendants(matching: .any).matching(identifier: "languageNameLabel").firstMatch
        let bigLabel = app.descendants(matching: .any).matching(identifier: "bigLabel").firstMatch

        _ = nameLabel.waitForExistence(timeout: 3)
        _ = bigLabel.waitForExistence(timeout: 1)

        let nameLabelText = (nameLabel.value as? String) ?? nameLabel.label
        let bigLabelText = (bigLabel.value as? String) ?? bigLabel.label

        XCTAssertTrue(
            !nameLabelText.isEmpty || !bigLabelText.isEmpty,
            "Window must contain at least one non-empty text label"
        )

        let hide = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: window)
        wait(for: [hide], timeout: 8)
    }

    /// Disabling the Caps Lock indicator preference prevents the window from appearing.
    func testCapsLockIndicatorPreferenceOffPreventsWindow() throws {
        try ensureCapsLockPreferenceEnabled()
        setCapsLockPreference(enabled: false)

        // Press Caps Lock — window must NOT appear
        holdCapsLock()
        sleep(2)

        let window = app.windows["LanguageIndicatorWindow"]
        XCTAssertFalse(window.exists, "Window must NOT appear when the Caps Lock indicator is disabled")

        // Restore preference so tearDown leaves state clean
        try ensureCapsLockPreferenceEnabled()
    }

    /// Rapid successive Caps Lock presses must not crash the app or leave a stale window.
    func testRapidCapsLockPressesAppRemainsResponsive() throws {
        try ensureCapsLockPreferenceEnabled()

        // 4 rapid presses: ON / OFF / ON / OFF
        for _ in 1...4 {
            pressCapsLockToChangeLanguage()
        }

        // App must still be alive
        let statusItem = app.statusItems.firstMatch
        XCTAssertTrue(
            statusItem.waitForExistence(timeout: 3),
            "Status bar item should still be accessible after rapid Caps Lock presses"
        )

        // After displayDuration(1) + animation(0.4) + buffer, all windows should be hidden
        let window = app.windows["LanguageIndicatorWindow"]
        let settled = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: window)
        wait(for: [settled], timeout: 10)
    }

    /// Pressing Caps Lock while the window is already visible resets the hide timer
    /// so the window stays on screen for a full display duration from the new press.
    func testCapsLockWhileWindowVisibleResetsTimer() throws {
        try ensureCapsLockPreferenceEnabled()

        let window = app.windows["LanguageIndicatorWindow"]

        // First press — window appears
        holdCapsLock()
        XCTAssertTrue(window.waitForExistence(timeout: 3))

        // Immediately press again while window is still visible
        pressCapsLockToChangeLanguage()
        XCTAssertTrue(window.exists, "Window should still be visible immediately after second press")

        // Window must eventually hide
        let hide = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: window)
        wait(for: [hide], timeout: 10)
    }

    // MARK: - Helpers

    /// Simulates a Caps Lock key press + release via CGEvent (virtual key 0x39).
    ///
    /// The key is held for 1.5 s to cross the macOS "hold to activate Caps Lock"
    /// threshold, which is required when the system is configured to use a tap
    /// for switching input sources (System Settings → Keyboard → "Use Caps Lock key
    /// to switch to and from last used Latin input source").
    /// Taps Caps Lock (~100 ms) — triggers a language/input source switch
    /// on systems where tap = switch language, hold = activate Caps Lock.
    private func pressCapsLockToChangeLanguage() {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x39, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x39, keyDown: false)
        keyDown?.post(tap: .cgSessionEventTap)
        usleep(300_000)  // short tap — does NOT cross the hold threshold
        keyUp?.post(tap: .cgSessionEventTap)
        usleep(200_000)  // settle
    }

    /// Holds Caps Lock (~600 ms) — activates the Caps Lock toggle.
    /// 600 ms crosses the macOS hold threshold (~300 ms) while leaving the
    /// window (display duration 1 s) still visible after this function returns.
    private func holdCapsLock() {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x39, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x39, keyDown: false)
        keyDown?.post(tap: .cgSessionEventTap)
        usleep(600_000)  // hold long enough to trigger Caps Lock (~300ms threshold), returns while window still visible
        keyUp?.post(tap: .cgSessionEventTap)
        usleep(200_000)  // settle
    }

    /// Opens preferences, navigates to General, and ensures the Caps Lock toggle is ON.
    private func ensureCapsLockPreferenceEnabled() throws {
        let statusItem = app.statusItems.firstMatch

        guard statusItem.waitForExistence(timeout: 3) else {
            XCTFail("Status bar item not found"); return
        }

        statusItem.click()
//        sleep(1) // wait for menu to fully open and render

        let prefsItem = app.menuItems["Preferences..."]

        guard prefsItem.waitForExistence(timeout: 3) else {
            XCTFail("Preferences menu item not found"); return
        }

        prefsItem.click()
        _ = app.windows["LanguageFlag Preferences"].waitForExistence(timeout: 10)

        let generalTab = app.tabs["General"]
        if generalTab.waitForExistence(timeout: 3) { generalTab.click() }

        let prefsWindow = app.windows["LanguageFlag Preferences"]

        // Scroll to the bottom to ensure the caps lock toggle is visible
        let scrollView = prefsWindow.scrollViews.firstMatch
        if scrollView.waitForExistence(timeout: 2) {
            scrollView.scroll(byDeltaX: 0, deltaY: -300)
//            sleep(1)
        }

        let toggle = prefsWindow
            .descendants(matching: .any)
            .matching(identifier: "capsLockToggle")
            .firstMatch

        guard toggle.waitForExistence(timeout: 3) else {
            XCTFail("Caps Lock toggle not found"); return
        }

        // Turn on if currently off
        if toggle.value as? String == "0" || toggle.value as? Int == 0 {
            toggle.click()
//            sleep(1)
        }

        // Close preferences window
        prefsWindow.buttons[XCUIIdentifierCloseWindow].click()
//        sleep(1)
    }

    /// Opens preferences and sets the Caps Lock toggle to the given state.
    private func setCapsLockPreference(enabled: Bool) {
        let statusItem = app.statusItems.firstMatch

        guard statusItem.waitForExistence(timeout: 3) else {
            XCTFail("Status bar item not found")
            return
        }

        statusItem.click()
        sleep(1) // wait for menu to fully open and render

        let prefsItem = app.menuItems["Preferences..."]

        guard prefsItem.waitForExistence(timeout: 3) else {
            XCTFail("Preferences menu item not found")
            return
        }

        prefsItem.click()
        _ = app.windows["LanguageFlag Preferences"].waitForExistence(timeout: 10)

        let generalTab = app.tabs["General"]
        if generalTab.waitForExistence(timeout: 3) { generalTab.click() }

        let prefsWindow = app.windows["LanguageFlag Preferences"]

        // Scroll to the bottom to ensure the caps lock toggle is visible
        let scrollView = prefsWindow.scrollViews.firstMatch
        if scrollView.waitForExistence(timeout: 2) {
            scrollView.scroll(byDeltaX: 0, deltaY: -300)
            sleep(1)
        }

        let toggle = prefsWindow.descendants(matching: .any)
            .matching(identifier: "capsLockToggle")
            .firstMatch

        guard toggle.waitForExistence(timeout: 3) else {
            XCTFail("Caps Lock toggle not found")
            return
        }

        let isOn = toggle.value as? String == "1" || toggle.value as? Int == 1

        if isOn != enabled {
            toggle.click()
            sleep(1)
        }

        prefsWindow.buttons[XCUIIdentifierCloseWindow].click()
        sleep(1)
    }
}
