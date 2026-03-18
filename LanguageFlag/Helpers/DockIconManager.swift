import Cocoa
import Carbon
import Combine

/// Manages the dock icon: shows/hides it and keeps the icon image in sync with the current keyboard layout.
final class DockIconManager {

    // MARK: - Properties
    private let preferences = UserPreferences.shared
    private let layoutImageContainer = LayoutImageContainer.shared
    private var cancellables = Set<AnyCancellable>()

    // Keeps a hidden window alive so macOS doesn't remove the dock icon when all visible windows close
    private var anchorWindow: NSWindow?

    // The last known layout info, used to refresh the dock image when the preference is toggled on
    private var currentLayoutID: String = ""
    private var currentLayoutName: String = ""

    // MARK: - Initialization
    init() {
        // Seed with current layout so the dock icon is correct on launch
        let currentSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        currentLayoutID = currentSource.id
        currentLayoutName = currentSource.name

        observePreference()
        observeLayoutChanges()

        // Apply saved preference immediately on launch
        applyActivationPolicy(showDock: preferences.showDockIndicator)
        refreshDockImage()
    }
}

// MARK: - Private
extension DockIconManager {

    private func observePreference() {
        preferences.$showDockIndicator
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                self?.applyActivationPolicy(showDock: show)
                if show {
                    self?.refreshDockImage()
                }
            }
            .store(in: &cancellables)
    }

    private func observeLayoutChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLayoutChange(_:)),
            name: .keyboardLayoutChanged,
            object: nil
        )
    }

    @objc
    private func handleLayoutChange(_ notification: NSNotification) {
        guard let model = notification.object as? KeyboardLayoutNotification else { return }
        currentLayoutID = model.keyboardLayoutID
        currentLayoutName = model.keyboardLayout
        if preferences.showDockIndicator {
            refreshDockImage()
        }
    }

    private func applyActivationPolicy(showDock: Bool) {
        let target: NSApplication.ActivationPolicy = showDock ? .regular : .accessory

        if showDock {
            // Keep a hidden off-screen window alive so macOS doesn't drop
            // the dock icon when all visible windows are closed.
            if anchorWindow == nil {
                let window = NSWindow(
                    contentRect: NSRect(x: -10000, y: -10000, width: 1, height: 1),
                    styleMask: [],
                    backing: .buffered,
                    defer: true
                )
                window.isReleasedWhenClosed = false
                anchorWindow = window
            }
        } else {
            anchorWindow = nil
            // If a window (e.g. preferences) is currently visible, don't call
            // setActivationPolicy(.accessory) now — it would close that window.
            // PreferencesWindowController.windowWillClose handles the revert instead.
            let hasVisibleWindow = NSApp.windows.contains { $0.isVisible }
            if !hasVisibleWindow {
                NSApp.setActivationPolicy(.accessory)
            }

            return
        }

        guard NSApp.activationPolicy() != target else { return }

        NSApp.setActivationPolicy(target)
    }

    private func refreshDockImage() {
        guard preferences.showDockIndicator else { return }

        if let image = layoutImageContainer.getImage(forID: currentLayoutID, name: currentLayoutName) {
            NSApp.applicationIconImage = makeDockImage(from: image)
        } else {
            NSApp.applicationIconImage = nil
        }
    }

    /// Renders `flagImage` centered in a square canvas, preserving its aspect ratio.
    private func makeDockImage(from flagImage: NSImage) -> NSImage {
        let canvasSize: CGFloat = 512
        let canvas = NSImage(size: NSSize(width: canvasSize, height: canvasSize))
        canvas.lockFocus()

        defer { canvas.unlockFocus() }

        let srcSize = flagImage.size

        guard srcSize.width > 0, srcSize.height > 0 else { return flagImage }

        let aspect = srcSize.width / srcSize.height
        let drawWidth: CGFloat
        let drawHeight: CGFloat

        if aspect >= 1 {
            drawWidth = canvasSize
            drawHeight = (canvasSize / aspect).rounded()
        } else {
            drawHeight = canvasSize
            drawWidth = (canvasSize * aspect).rounded()
        }

        let origin = NSPoint(
            x: ((canvasSize - drawWidth) / 2).rounded(),
            y: ((canvasSize - drawHeight) / 2).rounded()
        )

        flagImage.draw(in: NSRect(origin: origin, size: NSSize(width: drawWidth, height: drawHeight)))

        return canvas
    }
}
