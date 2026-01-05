//
//  PreferencesWindowController.swift
//  LanguageFlag
//
//  Created by Claude on 01/01/2026.
//

import Cocoa
import SwiftUI

final class PreferencesWindowController: NSWindowController {

    convenience init() {
        let hostingController = NSHostingController(rootView: PreferencesView())
        let window = NSWindow(contentViewController: hostingController)

        window.title = "LanguageFlag Preferences"
        window.styleMask = [.titled, .closable, .miniaturizable, .hudWindow]
        window.isReleasedWhenClosed = false

        self.init(window: window)
    }

    func show() {
        guard let window = window else { return }

        // Always center on current monitor when showing
        centerOnCurrentMonitor(window: window)

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
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
