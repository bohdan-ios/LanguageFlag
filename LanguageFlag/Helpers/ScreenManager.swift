import Cocoa

class ScreenManager {

    // MARK: - Variables
    private var windowControllers: [String: LanguageWindowController] = [:]

    // MARK: - Init
    init() {
        setupObservers()
        ensureWindowControllersForAllScreens()
    }

    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Private
extension ScreenManager {

    /// Sets up observers for screen parameter changes.
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    /// Handles screen parameter changes and refreshes windows.
    @objc
    private func screenParametersDidChange() {
        ensureWindowControllersForAllScreens()
    }

    /// Ensures window controllers exist for all screens (lazy loading).
    private func ensureWindowControllersForAllScreens() {
        let currentScreens = NSScreen.screens
        let currentScreenIds = Set(currentScreens.map { $0.identifier })
        let existingScreenIds = Set(windowControllers.keys)

        // Remove controllers for screens that no longer exist
        let removedScreenIds = existingScreenIds.subtracting(currentScreenIds)
        for screenId in removedScreenIds {
            windowControllers[screenId]?.close()
            windowControllers.removeValue(forKey: screenId)
        }

        // Add controllers for new screens
        for screen in currentScreens {
            let screenId = screen.identifier

            if windowControllers[screenId] == nil {
                windowControllers[screenId] = createWindowController(for: screen)
            }
        }
    }

    /// Creates a window controller for a specific screen.
    private func createWindowController(for screen: NSScreen) -> LanguageWindowController {
        let windowController = LanguageWindowController()
        windowController.screenRect = screen.frame
        windowController.windowDidLoad()

        return windowController
    }
}
