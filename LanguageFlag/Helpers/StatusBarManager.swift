import Cocoa
import LaunchAtLogin
import Carbon

final class StatusBarManager {

    // MARK: - Properties
    private let statusItem: NSStatusItem
    private let layoutImageContainer: LayoutImageContainer
    private let menuBuilder: StatusBarMenuBuilder
    private var previousModel: KeyboardLayoutNotification?
    private lazy var preferencesWindowController = PreferencesWindowController()

    // MARK: - Initialization
    init(
        layoutImageContainer: LayoutImageContainer = LayoutImageContainer.shared,
        menuBuilder: StatusBarMenuBuilder = StatusBarMenuBuilder()
    ) {
        self.layoutImageContainer = layoutImageContainer
        self.menuBuilder = menuBuilder
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        setupStatusBar()
        addObservers()
    }

    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Setup Methods
private extension StatusBarManager {

    /// Configures the status bar and menu items.
    func setupStatusBar() {
        // Build and assign the menu
        let menu = menuBuilder.buildMenu(
            launchAtLoginAction: #selector(toggleLaunchAtLogin),
            preferencesAction: #selector(openPreferences),
            exitAction: #selector(exitApplication),
            target: self
        )
        statusItem.menu = menu

        // Set the initial icon or title
        let keyboardLayout = TISCopyCurrentKeyboardInputSource().takeUnretainedValue().name
        updateStatusBarIcon(for: keyboardLayout)
    }

    /// Subscribes to relevant notifications.
    func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardLayoutChanged),
            name: .keyboardLayoutChanged,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(capsLockChanged),
            name: .capsLockChanged,
            object: nil
        )
    }
}

// MARK: - Actions
private extension StatusBarManager {

    /// Handles keyboard layout change notifications.
    @objc
    func keyboardLayoutChanged(notification: NSNotification) {
        guard let model = notification.object as? KeyboardLayoutNotification else { return }

        previousModel = model
        updateStatusBarIcon(for: model)
    }

    @objc
    func capsLockChanged(notification: NSNotification) {
        guard
            let newCapsLockState = notification.object as? Bool,
            let previousModel
        else {
            return
        }

        let newModel = KeyboardLayoutNotification(keyboardLayout: previousModel.keyboardLayout,
                                                  isCapsLockEnabled: newCapsLockState,
                                                  iconRef: previousModel.iconRef)
        updateStatusBarIcon(for: newModel)
    }
    
    /// Toggles the Launch at Login state.
    @objc
    func toggleLaunchAtLogin(_ sender: NSMenuItem?) {
        LaunchAtLogin.isEnabled.toggle()
        sender?.state = LaunchAtLogin.isEnabled ? .on : .off
    }

    /// Opens the preferences window.
    @objc
    func openPreferences() {
        preferencesWindowController.show()
    }

    /// Exits the application.
    @objc
    func exitApplication() {
        NSApplication.shared.terminate(self)
    }
}

// MARK: - Helper Methods
private extension StatusBarManager {

    /// Updates the status bar icon or title based on the keyboard layout.
    func updateStatusBarIcon(for keyboardLayout: String?) {
        let iconSize = NSSize(width: 24, height: 24)

        if let keyboardLayout = keyboardLayout {
            let flagImage = layoutImageContainer.getFlagItem(for: keyboardLayout, size: iconSize)
            statusItem.button?.image = flagImage ?? createDefaultIcon(size: iconSize)
            statusItem.button?.title = ""
        } else {
            statusItem.button?.image = createDefaultIcon(size: iconSize)
            statusItem.button?.title = ""
        }
    }
    
    func updateStatusBarIcon(for model: KeyboardLayoutNotification) {
        let iconSize = NSSize(width: 24, height: 24)
        
        let flagImage = layoutImageContainer.getFlagItem(for: model.keyboardLayout, size: iconSize)
        
        if let flagImage {
            statusItem.button?.image = flagImage
            statusItem.button?.title = ""
        } else {
            statusItem.button?.image = createDefaultIcon(size: iconSize)
            statusItem.button?.title = ""
        }
    }
    
    func isCapsLockOn() -> Bool {
        let flags = CGEventSource.flagsState(.combinedSessionState)
        return flags.contains(.maskAlphaShift)
    }
    
    func createDefaultIcon(size: NSSize) -> NSImage {
        // Create an image using a drawing handler for better resolution scaling
        NSImage(size: size, flipped: false) { rect in
            let emoji = "💂‍♀️" as NSString
            let fontSize = size.height * 0.75 // Adjust scale to fit nicely
            let font = NSFont.systemFont(ofSize: fontSize)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            
            // Calculate center position
            let stringSize = emoji.size(withAttributes: attributes)
            let point = NSPoint(
                x: rect.midX - stringSize.width / 2,
                y: rect.midY - stringSize.height / 2
            )
            
            emoji.draw(at: point, withAttributes: attributes)
            return true
        }
    }
}
