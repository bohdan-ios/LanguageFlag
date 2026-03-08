import XCTest

final class LaunchAtLoginUITests: XCTestCase {

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

    /// Verifies the "Launch at login" menu item exists in the status bar menu
    func testLaunchAtLoginMenuItemExists() throws {
        openMenu()

        let item = app.menuItems["Launch at login"]
        XCTAssertTrue(item.waitForExistence(timeout: 3), "Launch at login menu item should exist")

        // Dismiss menu
        app.typeKey(.escape, modifierFlags: [])
    }

    /// Verifies clicking "Launch at login" is interactive and the menu re-opens cleanly
    func testLaunchAtLoginToggles() throws {
        openMenu()

        let item = app.menuItems["Launch at login"]
        XCTAssertTrue(item.waitForExistence(timeout: 3), "Launch at login item should exist")
        XCTAssertTrue(item.isEnabled, "Launch at login item should be enabled")

        item.click()

        // Menu closes after click — verify app is still alive and menu re-opens
        openMenu()
        let updatedItem = app.menuItems["Launch at login"]
        XCTAssertTrue(updatedItem.waitForExistence(timeout: 3), "Item should still exist after toggle")
        XCTAssertTrue(updatedItem.isEnabled, "Item should remain enabled after toggle")

        // Restore
        updatedItem.click()
    }

    /// Verifies clicking "Launch at login" twice returns to the original state
    func testLaunchAtLoginDoubleToggleRestores() throws {
        openMenu()
        let item = app.menuItems["Launch at login"]
        XCTAssertTrue(item.waitForExistence(timeout: 3))
        let initialState = item.value as? String

        // First toggle
        item.click()

        // Second toggle
        openMenu()
        let item2 = app.menuItems["Launch at login"]
        XCTAssertTrue(item2.waitForExistence(timeout: 3))
        item2.click()

        // Verify restored
        openMenu()
        let item3 = app.menuItems["Launch at login"]
        XCTAssertTrue(item3.waitForExistence(timeout: 3))
        XCTAssertEqual(item3.value as? String, initialState, "State should be restored after two toggles")

        // Dismiss
        app.typeKey(.escape, modifierFlags: [])
    }

    // MARK: - Helpers

    private func openMenu() {
        let statusItem = app.statusItems.firstMatch
        guard statusItem.waitForExistence(timeout: 3) else {
            XCTFail("Status bar item not found")
            return
        }
        statusItem.click()
        _ = app.menuItems["Launch at login"].waitForExistence(timeout: 3)
    }
}
