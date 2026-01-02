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
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.center()
        window.setFrameAutosaveName("PreferencesWindow")
        window.isReleasedWhenClosed = false

        self.init(window: window)
    }

    func show() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
