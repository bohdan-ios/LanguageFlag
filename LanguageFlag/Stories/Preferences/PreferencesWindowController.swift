import Cocoa
import SwiftUI

final class PreferencesWindowController: NSWindowController, NSWindowDelegate {

    // MARK: - Constants
    private enum WindowSize {

        static let width: CGFloat = 809
        static let height: CGFloat = 500
    }

    // MARK: - Variables
    private var settingsWindow: NSWindow?

    // MARK: - Init
    convenience init() {
        let hostingController = NSHostingController(rootView: PreferencesView())
        let window = NSWindow(contentViewController: hostingController)

        window.title = "LanguageFlag Preferences"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false

        window.setContentSize(NSSize(width: WindowSize.width, height: WindowSize.height))

        self.init(window: window)
        window.delegate = self

        self.settingsWindow = window

        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.origin.x + (screenFrame.width - WindowSize.width) / 2
            let y = screenFrame.origin.y + (screenFrame.height - WindowSize.height) / 2

            window.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }

    // MARK: - Internal
    func show() {
        guard let window else { return }

        // Show dock icon while preferences are open
        NSApp.setActivationPolicy(.regular)

        // Center on current monitor when showing (for multi-monitor support)
        centerOnCurrentMonitor(window: window)

        window.isReleasedWhenClosed = false
        window.isRestorable = false

        // Bring window to front
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window.orderFrontRegardless()
    }

    // MARK: - NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        // Hide dock icon when preferences are closed
        NSApp.setActivationPolicy(.accessory)
    }
}

// MARK: - Private
extension PreferencesWindowController {

    /// Centers the window on the monitor containing the mouse cursor
    private func centerOnCurrentMonitor(window: NSWindow) {
        // Get mouse location and find the screen containing it
        let mouseLocation = NSEvent.mouseLocation
        let currentScreen = NSScreen.screens.first { screen in
            screen.frame.contains(mouseLocation)
        } ?? NSScreen.main ?? NSScreen.screens.first
        
        guard let screen = currentScreen else {
            window.center()
            return
        }
        
        // Calculate centered position on the current screen
        let screenFrame = screen.visibleFrame
        let windowSize = window.frame.size
        
        let x = screenFrame.origin.x + (screenFrame.width - windowSize.width) / 2
        let y = screenFrame.origin.y + (screenFrame.height - windowSize.height) / 2
        
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
