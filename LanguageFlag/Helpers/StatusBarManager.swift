import Cocoa
import LaunchAtLogin
import Carbon
import Combine

// MARK: - MenuDelegate helper
private final class MenuDelegate: NSObject, NSMenuDelegate {

    var onWillOpen: (() -> Void)?

    func menuWillOpen(_ menu: NSMenu) {
        onWillOpen?()
    }
}

final class StatusBarManager {

    // MARK: - Properties
    private let statusItem: NSStatusItem
    private let layoutImageContainer: LayoutImageContainer
    private let menuBuilder: StatusBarMenuBuilder
    private let menuDelegate = MenuDelegate()
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

    /// Configures the status bar and initial menu.
    func setupStatusBar() {
        let menu = menuBuilder.buildMenu(
            launchAtLoginAction: #selector(toggleLaunchAtLogin),
            preferencesAction: #selector(openPreferences),
            exitAction: #selector(exitApplication),
            target: self
        )
        menu.delegate = menuDelegate
        statusItem.menu = menu

        menuDelegate.onWillOpen = { [weak self] in
            self?.rebuildMenuContents()
        }

        let currentSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        let initialModel = KeyboardLayoutNotification(keyboardLayout: currentSource.name,
                                                      keyboardLayoutID: currentSource.id,
                                                      isCapsLockEnabled: false,
                                                      iconRef: currentSource.iconRef)
        updateStatusBarIcon(for: initialModel)
    }

    /// Rebuilds the menu contents in-place (called lazily when menu opens).
    func rebuildMenuContents() {
        guard let menu = statusItem.menu else { return }

        let fresh = menuBuilder.buildMenu(
            launchAtLoginAction: #selector(toggleLaunchAtLogin),
            preferencesAction: #selector(openPreferences),
            exitAction: #selector(exitApplication),
            target: self
        )

        menu.removeAllItems()

        // Snapshot items before mutating fresh, then transfer ownership one-by-one
        let items = fresh.items
        for item in items {
            fresh.removeItem(item)
            menu.addItem(item)
        }

        menu.delegate = menuDelegate
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
                                                  keyboardLayoutID: previousModel.keyboardLayoutID,
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

        let inputSources = TISCreateInputSourceList(nil, false).takeRetainedValue() as? [TISInputSource] ?? []
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

        if let firstLayout = group.layouts.first {
            let inputSources = TISCreateInputSourceList(nil, false).takeRetainedValue() as? [TISInputSource] ?? []
            if let source = inputSources.first(where: { $0.name == firstLayout }) {
                TISSelectInputSource(source)
            }
        }
    }
    #endif
}

// MARK: - Helper Methods
private extension StatusBarManager {

    /// Updates the status bar icon or title based on the keyboard layout.
    func updateStatusBarIcon(for keyboardLayout: String?) {
        let height: CGFloat = 24
        let defaultSize = NSSize(width: height, height: height)

        if let keyboardLayout = keyboardLayout {
            let flagImage: NSImage?
            if let baseImage = layoutImageContainer.getImage(for: keyboardLayout) {
                let iconSize = statusBarIconSize(for: baseImage, height: height)
                flagImage = layoutImageContainer.getFlagItem(for: keyboardLayout, size: iconSize)
            } else {
                flagImage = nil
            }
            statusItem.button?.image = flagImage ?? createDefaultIcon(size: defaultSize)
            statusItem.button?.title = preferences.showInMenuBar ? " \(keyboardLayout)" : ""
        } else {
            statusItem.button?.image = createDefaultIcon(size: defaultSize)
            statusItem.button?.title = ""
        }
    }

    func updateStatusBarIcon(for model: KeyboardLayoutNotification) {
        let height: CGFloat = 24
        let defaultSize = NSSize(width: height, height: height)

        let flagImage: NSImage?
        if let baseImage = layoutImageContainer.getImage(forID: model.keyboardLayoutID, name: model.keyboardLayout) {
            let iconSize = statusBarIconSize(for: baseImage, height: height)
            flagImage = layoutImageContainer.getFlagItem(forID: model.keyboardLayoutID, name: model.keyboardLayout, size: iconSize)
        } else {
            flagImage = nil
        }

        statusItem.button?.image = flagImage ?? createDefaultIcon(size: defaultSize)
        statusItem.button?.title = preferences.showInMenuBar ? " \(model.keyboardLayout)" : ""
    }

    /// Returns an icon size that preserves the image's aspect ratio at the given menu bar height.
    private func statusBarIconSize(for image: NSImage, height: CGFloat) -> NSSize {
        let aspectRatio = image.size.height > 0 ? image.size.width / image.size.height : 1
        return NSSize(width: (height * aspectRatio).rounded(), height: height)
    }

    func createDefaultIcon(size: NSSize) -> NSImage {
        NSImage(size: size, flipped: false) { rect in
            let emoji = "💂‍♀️" as NSString
            let fontSize = size.height * 0.75
            let font = NSFont.systemFont(ofSize: fontSize)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]

            let stringSize = emoji.size(withAttributes: attributes)
            let point = NSPoint(
                x: rect.midX - stringSize.width / 2,
                y: rect.midY - stringSize.height / 2
            )

            emoji.draw(at: point, withAttributes: attributes)
            return true
        }
    }

    #if FEATURE_ANALYTICS
    func initializeAnalytics() {
        let currentLayout = TISCopyCurrentKeyboardInputSource().takeRetainedValue().name
        analytics.startTracking(layout: currentLayout)
    }
    #endif

    func observePreferencesChanges() {
        preferences.$showInMenuBar
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                let source = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
                let model = KeyboardLayoutNotification(keyboardLayout: source.name,
                                                       keyboardLayoutID: source.id,
                                                       isCapsLockEnabled: false,
                                                       iconRef: source.iconRef)
                self?.updateStatusBarIcon(for: model)
            }
            .store(in: &cancellables)
    }
}
