import Cocoa
import Carbon

class CapsLockManager {

    // MARK: - Variables
    private(set) var isCapsLockEnabled: Bool = false
    private var globalEventMonitor: Any?
    private var localEventMonitor: Any?

    // MARK: - Init
    init() {
        isCapsLockEnabled = CGEventSource.flagsState(.combinedSessionState).contains(.maskAlphaShift)
        setupCapsLockObservers()
    }

    deinit {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    func isCapsLockOn() -> Bool {
        let flags = CGEventSource.flagsState(.combinedSessionState)

        return flags.contains(.maskAlphaShift)
    }
}

// MARK: - Private
extension CapsLockManager {
    
    /// Sets up observers to monitor Caps Lock state changes locally and globally.
    private func setupCapsLockObservers() {
        // Global monitor for when the app is in the background
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleCapsLockStateChange(event: event)
        }
        
        // Local monitor for when the app (e.g., Preferences window) is active
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleCapsLockStateChange(event: event)
            return event
        }
    }

    /// Handles Caps Lock state changes.
    private func handleCapsLockStateChange(event: NSEvent) {
        let capsLockEnabled = event.modifierFlags.contains(.capsLock)

        if isCapsLockEnabled != capsLockEnabled {
            isCapsLockEnabled = capsLockEnabled
            notifyCapsLockStateChanged(newCapsLockEnabled: capsLockEnabled)
        }
    }

    /// Notifies observers about the Caps Lock state change.
    private func notifyCapsLockStateChanged(newCapsLockEnabled: Bool) {
        guard UserPreferences.shared.showCapsLockIndicator else { return }

        NotificationCenter.default.post(name: .capsLockChanged, object: newCapsLockEnabled)
    }
}
