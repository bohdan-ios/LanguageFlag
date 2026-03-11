import Testing
import Foundation
@testable import LanguageFlag

@Suite("StatusBarMenuBuilder Tests")
struct StatusBarMenuBuilderTests {

    @Test("buildMenu does not crash and returns a non-empty menu")
    func testBuildMenuReturnsNonEmptyMenu() {
        let builder = StatusBarMenuBuilder()

        // Use a dummy target – selectors are not invoked during construction.
        let target = NSObject()
        let menu = builder.buildMenu(
            launchAtLoginAction: NSSelectorFromString("toggleLaunchAtLogin:"),
            preferencesAction: NSSelectorFromString("openPreferences"),
            exitAction: NSSelectorFromString("exitApplication"),
            target: target
        )

        #expect(menu.items.isEmpty == false)
    }
}
