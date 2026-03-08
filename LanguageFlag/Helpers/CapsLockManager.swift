import Cocoa
import Carbon

class CapsLockManager {

    // MARK: - Variables
    private(set) var isCapsLockEnabled: Bool = false
    private var eventMonitor: Any?

    // MARK: - Init
    init() {
        setupCapsLockObserver()
    }

    deinit {
        if let monitor = eventMonitor {
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
    
    /// Sets up an observer to monitor Caps Lock state changes.
    private func setupCapsLockObserver() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleCapsLockStateChange(event: event)
        }
    }
    
    /// Handles Caps Lock state changes.
    private func handleCapsLockStateChange(event: NSEvent) {
        let capsLockEnabled = isCapsLockOn()

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
