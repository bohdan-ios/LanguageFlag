import Cocoa
import QuartzCore
import Combine

class ScreenManager {

    // MARK: - Variables
    private var windowControllers: [String: LanguageWindowController] = [:]
    private var cancellables = Set<AnyCancellable>()
    private let preferences = UserPreferences.shared

    // MARK: - Init
    init() {
        setupObservers()
        ensureWindowControllersForAllScreens()
        observePreferencesChanges()
    }

    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
        cancellables.removeAll()
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(forceRecalculateFrames),
            name: .recalculateWindowFrames,
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

    /// Force recalculates all window frames (clears and rebuilds)
    @objc
    private func forceRecalculateFrames() {
        // Close all existing windows
        for (_, controller) in windowControllers {
            controller.window?.orderOut(nil)
            controller.window?.close()
            controller.close()
        }
        windowControllers.removeAll()

        // Rebuild for all screens
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
            if let controller = windowControllers[screenId] {
                // Fully destroy the window
                if let win = controller.window {
                    win.orderOut(nil)
                    win.close()
                }
                controller.window = nil  // Explicitly nil the reference
                controller.close()
            }
            windowControllers.removeValue(forKey: screenId)
        }

        // Add or update controllers for all screens
        var controllersToUpdate: [LanguageWindowController] = []

        for screen in currentScreens {
            let screenId = screen.identifier

            if let existingController = windowControllers[screenId] {
                // Update the screenRect for existing controller (Dock may have moved)
                existingController.screenRect = screen.visibleFrame
                controllersToUpdate.append(existingController)
            } else {
                // Create new controller for new screen
                windowControllers[screenId] = createWindowController(for: screen)
            }
        }

        // Update all frames simultaneously using CATransaction to batch animations
        if !controllersToUpdate.isEmpty {
            DispatchQueue.main.async {
                CATransaction.begin()

                for controller in controllersToUpdate {
                    controller.updateWindowFrameIfNeeded()
                }

                CATransaction.commit()
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

    /// Observes preference changes that affect all windows
    private func observePreferencesChanges() {
        // Observe display position changes
        preferences.$displayPosition
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAllWindowFrames()
            }
            .store(in: &cancellables)

        // Observe window size changes
        preferences.$windowSize
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAllWindowFrames()
            }
            .store(in: &cancellables)
    }

    /// Updates all window frames simultaneously
    private func updateAllWindowFrames() {
        let controllers = Array(windowControllers.values)

        guard !controllers.isEmpty else { return }

        // Update all frames simultaneously using CATransaction
        CATransaction.begin()

        for controller in controllers {
            controller.updateWindowFrameIfNeeded()
        }

        CATransaction.commit()
    }
}
