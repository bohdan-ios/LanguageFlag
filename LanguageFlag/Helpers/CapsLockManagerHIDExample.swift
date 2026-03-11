/// Alternative IOKit HID implementation for Caps Lock observation.
///
/// Key differences from NSEvent-based approach:
/// - Works without Accessibility permission (read-only HID observation is allowed)
/// - Receives raw hardware events directly, before the OS processes them
/// - Slightly more complex setup; requires manual RunLoop scheduling and cleanup
///
/// This file is an illustrative example and is not used by the app.
/// The production implementation is in CapsLockManager.swift.
///
/// Add these keys to Info.plist
///     <key>NSInputMonitoringUsageDescription</key>
///     <string>LanguageFlag monitors keyboard input to detect Caps Lock state changes.</string>

import Cocoa
import IOKit
import IOKit.hid

class CapsLockManagerHID {

    // MARK: - Variables
    private var hidManager: IOHIDManager?
    private(set) var isCapsLockEnabled: Bool = false
    // Timestamp of the last processed key-down; used to debounce Karabiner's
    // double-fire (virtual keyboard + physical keyboard both report value=1).
    private var lastToggleTime: TimeInterval = 0

    // MARK: - Init
    init() {
        isCapsLockEnabled = CGEventSource.flagsState(.combinedSessionState).contains(.maskAlphaShift)
        setupHIDObserver()
    }

    deinit {
        if let manager = hidManager {
            IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
            IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        }
    }
}

// MARK: - Private
private extension CapsLockManagerHID {

    func setupHIDObserver() {
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        hidManager = manager

        // Match all keyboard devices
        let deviceMatch: [String: Any] = [
            kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard
        ]
        IOHIDManagerSetDeviceMatching(manager, deviceMatch as CFDictionary)

        // Narrow input values to Caps Lock key only
        let valueMatch: [String: Any] = [
            kIOHIDElementUsagePageKey: kHIDPage_KeyboardOrKeypad,
            kIOHIDElementUsageKey: kHIDUsage_KeyboardCapsLock
        ]
        IOHIDManagerSetInputValueMatching(manager, valueMatch as CFDictionary)

        // Register the value callback using a C-compatible closure via context pointer
        let context = Unmanaged.passUnretained(self).toOpaque()

        IOHIDManagerRegisterInputValueCallback(
            manager,
            { context, _, _, value in
                // HID reports key-down (1) and key-up (0). Only react on key-down.
                guard IOHIDValueGetIntegerValue(value) == 1 else { return }
                guard let context else { return }

                let instance = Unmanaged<CapsLockManagerHID>.fromOpaque(context).takeUnretainedValue()

                // IOKit HID fires BEFORE the OS processes the Caps Lock toggle, so
                // CGEventSource still holds the old state at this point. Defer by one
                // RunLoop cycle to let the OS update the modifier flags first.
                // Multiple devices (e.g. Karabiner virtual keyboard + physical keyboard)
                // may both report value=1, but CGEventSource will return the same
                // already-toggled state for both, so the dedup guard prevents double notifications.
                // Debounce: Karabiner fires value=1 twice per press (virtual + physical
                // keyboard). The first event is accepted; subsequent events within
                // 150ms are dropped. This ensures only one deferred read is scheduled.
                let now = Date.timeIntervalSinceReferenceDate
                guard now - instance.lastToggleTime > 0.15 else {
                    print("[HID] duplicate event within debounce window, skipping")
                    return
                }
                instance.lastToggleTime = now

                // HID fires BEFORE the OS toggles the Caps Lock state. Wait 80ms so
                // CGEventSource returns the correct updated state, then read it directly
                // instead of self-managing a toggle (which drifts on missed events).
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    let newState = CGEventSource.flagsState(.combinedSessionState).contains(.maskAlphaShift)
                    print("[HID] deferred read: \(newState), current: \(instance.isCapsLockEnabled)")
                    guard instance.isCapsLockEnabled != newState else { return }

                    instance.isCapsLockEnabled = newState
                    print("[HID] posting .capsLockChanged with: \(newState)")
                    instance.notifyCapsLockStateChanged(newCapsLockEnabled: newState)
                }
            },
            context
        )

        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    func notifyCapsLockStateChanged(newCapsLockEnabled: Bool) {
        print("[HID] notifyCapsLockStateChanged — showCapsLockIndicator: \(UserPreferences.shared.showCapsLockIndicator), newState: \(newCapsLockEnabled)")
        guard UserPreferences.shared.showCapsLockIndicator else { return }

        NotificationCenter.default.post(name: .capsLockChanged, object: newCapsLockEnabled)
        print("[HID] notification posted")
    }
}
