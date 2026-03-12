import Foundation
import Carbon
import Combine

class NotificationManager {

    private let capsLockManager: CapsLockManager

    // MARK: - Init
    init(capsLockManager: CapsLockManager) {
        self.capsLockManager = capsLockManager
        setupObservers()
    }
}

// MARK: - Private
extension NotificationManager {

    /// Sets up all required notifications.
    private func setupObservers() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleInputSourceChange),
            name: NSNotification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String),
            object: nil
        )
    }

    /// Handles input source changes.
    @objc
    private func handleInputSourceChange() {
        let currentLayout = TISCopyCurrentKeyboardInputSource().takeUnretainedValue()
        let isCapsLockOn = capsLockManager.isCapsLockEnabled
        let model = KeyboardLayoutNotification(keyboardLayout: currentLayout.name,
                                               isCapsLockEnabled: isCapsLockOn,
                                               iconRef: currentLayout.iconRef)
        NotificationCenter.default.post(name: .keyboardLayoutChanged, object: model)
    }
}
