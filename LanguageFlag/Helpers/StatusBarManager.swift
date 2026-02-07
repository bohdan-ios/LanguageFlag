import Cocoa
import LaunchAtLogin
import Carbon
import Combine

final class StatusBarManager {

    // MARK: - Properties
    private let statusItem: NSStatusItem
    private let layoutImageContainer: LayoutImageContainer
    private let menuBuilder: StatusBarMenuBuilder
    private var previousModel: KeyboardLayoutNotification?
    private lazy var preferencesWindowController = PreferencesWindowController()
    private let preferences = UserPreferences.shared
    #if FEATURE_ANALYTICS
    private let analytics = LayoutAnalytics.shared
    #endif
    private var cancellables = Set<AnyCancellable>()

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
        observePreferencesChanges()
        #if FEATURE_ANALYTICS
        initializeAnalytics()
        #endif
    }
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
        cancellables.removeAll()
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
        #if FEATURE_ANALYTICS
        analytics.startTracking(layout: model.keyboardLayout)
        #endif

        // Update recent layouts
        menuBuilder.updateRecentLayouts(with: model.keyboardLayout)
        refreshMenu()
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

// MARK: - Public Actions
extension StatusBarManager {

    /// Switches to a specific layout.
    @objc
    func switchToLayout(_ sender: NSMenuItem) {
        guard let layoutName = sender.representedObject as? String else { return }

        // Find and activate the input source
        // swiftlint:disable:next force_cast
        let inputSources = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]
        if let source = inputSources.first(where: { $0.name == layoutName }) {
            TISSelectInputSource(source)
        }
    }

    #if FEATURE_GROUPS
    /// Activates a layout group.
    @objc
    func activateGroup(_ sender: NSMenuItem) {
        guard let group = sender.representedObject as? LayoutGroup else { return }

        LayoutGroupManager.shared.activeGroup = group

        // Switch to first layout in the group if available
        if let firstLayout = group.layouts.first {
            // swiftlint:disable:next force_cast
            let inputSources = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]
            if let source = inputSources.first(where: { $0.name == firstLayout }) {
                TISSelectInputSource(source)
            }
        }

        refreshMenu()
    }
    #endif
}

// MARK: - Helper Methods
private extension StatusBarManager {

    /// Updates the status bar icon or title based on the keyboard layout.
    func updateStatusBarIcon(for keyboardLayout: String?) {
        let iconSize = NSSize(width: 24, height: 24)

        if let keyboardLayout = keyboardLayout {
            let flagImage = layoutImageContainer.getFlagItem(for: keyboardLayout, size: iconSize)
            statusItem.button?.image = flagImage ?? createDefaultIcon(size: iconSize)
            
            // Show layout name if preference is enabled
            statusItem.button?.title = preferences.showInMenuBar ? " \(keyboardLayout)" : ""
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
        } else {
            statusItem.button?.image = createDefaultIcon(size: iconSize)
        }
        
        // Show layout name if preference is enabled
        statusItem.button?.title = preferences.showInMenuBar ? " \(model.keyboardLayout)" : ""
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

    func refreshMenu() {
        let menu = menuBuilder.buildMenu(
            launchAtLoginAction: #selector(toggleLaunchAtLogin),
            preferencesAction: #selector(openPreferences),
            exitAction: #selector(exitApplication),
            target: self
        )
        statusItem.menu = menu
    }

    #if FEATURE_ANALYTICS
    func initializeAnalytics() {
        let currentLayout = TISCopyCurrentKeyboardInputSource().takeUnretainedValue().name
        analytics.startTracking(layout: currentLayout)
    }
    #endif

    func observePreferencesChanges() {
        preferences.$showInMenuBar
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Re-apply current layout with updated preference
                let keyboardLayout = TISCopyCurrentKeyboardInputSource().takeUnretainedValue().name
                self?.updateStatusBarIcon(for: keyboardLayout)
            }
            .store(in: &cancellables)
    }
}
