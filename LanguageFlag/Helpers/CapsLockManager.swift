import Cocoa

class CapsLockManager {

    // MARK: - Variables
    private(set) var isCapsLockEnabled: Bool = false
    private var globalEventMonitor: Any?
    private var localEventMonitor: Any?
    private var debounceTask: DispatchWorkItem?

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

    /// Handles Caps Lock state changes using a debounce mechanism to ignore
    /// fast, transient layout-switching toggles created by macOS.
    private func handleCapsLockStateChange(event: NSEvent) {
        debounceTask?.cancel()

        let task = DispatchWorkItem { [weak self] in
            guard let self else { return }

            let capsLockEnabled = CGEventSource.flagsState(.combinedSessionState).contains(.maskAlphaShift)

            if isCapsLockEnabled != capsLockEnabled {
                isCapsLockEnabled = capsLockEnabled
                notifyCapsLockStateChanged(newCapsLockEnabled: capsLockEnabled)
            }
        }
        
        debounceTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: task)
    }

    /// Notifies observers about the Caps Lock state change.
    private func notifyCapsLockStateChanged(newCapsLockEnabled: Bool) {
        guard UserPreferences.shared.showCapsLockIndicator else { return }

        NotificationCenter.default.post(name: .capsLockChanged, object: newCapsLockEnabled)
    }
}
