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

    // MARK: - Public Methods
    /// Shows a preview of the language indicator with current settings
    func showPreview() {
        ensureWindowControllersForAllScreens()

        // Trigger the window display on all screens
        for controller in windowControllers.values {
            controller.showPreview()
        }
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(previewRequested),
            name: .preferencesPreviewRequested,
            object: nil
        )
    }

    /// Handles screen parameter changes and refreshes windows.
    @objc
    private func screenParametersDidChange() {
        ensureWindowControllersForAllScreens()
    }

    /// Handles preference preview requests.
    @objc
    private func previewRequested() {
        showPreview()
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
        windowController.screenRect = screen.visibleFrame
        windowController.windowDidLoad()

        return windowController
    }
}
