import Testing
import Foundation
@testable import LanguageFlag

@Suite("KeyboardLayoutNotification Tests")
struct KeyboardLayoutNotificationTests {

    // MARK: - Initialization

    @Test("can be created with a keyboard layout string")
    func testInitWithLayout() {
        let notification = KeyboardLayoutNotification(
            keyboardLayout: "US",
            isCapsLockEnabled: false,
            iconRef: nil
        )
        #expect(notification.keyboardLayout == "US")
    }

    @Test("isCapsLockEnabled is stored correctly when true")
    func testCapsLockTrue() {
        let notification = KeyboardLayoutNotification(
            keyboardLayout: "French",
            isCapsLockEnabled: true,
            iconRef: nil
        )
        #expect(notification.isCapsLockEnabled == true)
    }

    @Test("isCapsLockEnabled is stored correctly when false")
    func testCapsLockFalse() {
        let notification = KeyboardLayoutNotification(
            keyboardLayout: "German",
            isCapsLockEnabled: false,
            iconRef: nil
        )
        #expect(notification.isCapsLockEnabled == false)
    }

    @Test("iconRef is nil when not provided")
    func testIconRefNil() {
        let notification = KeyboardLayoutNotification(
            keyboardLayout: "US",
            isCapsLockEnabled: false,
            iconRef: nil
        )
        #expect(notification.iconRef == nil)
    }

    @Test("keyboardLayout stores unicode layout names")
    func testUnicodeLayoutName() {
        let notification = KeyboardLayoutNotification(
            keyboardLayout: "日本語",
            isCapsLockEnabled: false,
            iconRef: nil
        )
        #expect(notification.keyboardLayout == "日本語")
    }

    @Test("keyboardLayout stores empty string")
    func testEmptyLayoutName() {
        let notification = KeyboardLayoutNotification(
            keyboardLayout: "",
            isCapsLockEnabled: false,
            iconRef: nil
        )
        #expect(notification.keyboardLayout == "")
    }

    // MARK: - Multiple Instances

    @Test("two notifications with same data are independent values")
    func testIndependentInstances() {
        let n1 = KeyboardLayoutNotification(keyboardLayout: "US", isCapsLockEnabled: false, iconRef: nil)
        let n2 = KeyboardLayoutNotification(keyboardLayout: "US", isCapsLockEnabled: true, iconRef: nil)

        #expect(n1.isCapsLockEnabled != n2.isCapsLockEnabled)
        #expect(n1.keyboardLayout == n2.keyboardLayout)
    }

    @Test("all common keyboard layout names are stored correctly")
    func testCommonLayouts() {
        let layouts = ["US", "French", "German", "Spanish", "Japanese", "Chinese - Simplified", "Russian"]
        for layout in layouts {
            let notification = KeyboardLayoutNotification(
                keyboardLayout: layout,
                isCapsLockEnabled: false,
                iconRef: nil
            )
            #expect(notification.keyboardLayout == layout)
        }
    }
}
