//
//  AppDelegate.swift
//  LanguageFlag
//
//  Created by Bohdan on 18.04.2020.
//  Copyright © 2020 Bohdan. All rights reserved.
//

import Cocoa
import LaunchAtLogin

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Variables
    private var statusBarManager: StatusBarManager?
    private var dockIconManager: DockIconManager?
    private let screenManager: ScreenManager
    private let notificationManager: NotificationManager
    private let capsLockManager: CapsLockManager
    private let soundManager: SoundManager

    // MARK: - Initialization
    override init() {
        self.screenManager = ScreenManager()
        self.capsLockManager = CapsLockManager()
        self.notificationManager = NotificationManager(capsLockManager: capsLockManager)
        self.soundManager = SoundManager()

        super.init()
    }

    // MARK: - Life cycle
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarManager = StatusBarManager(soundManager: soundManager)
        dockIconManager = DockIconManager()

        // Disable window restoration for menu bar app
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")

        // ⚠️ Run once to regenerate Layout.json with stable source IDs.
        // Copy the Xcode console output to Layout.json, then delete this line.
        #if DEBUG
        LayoutMappingGenerator.printMapping()
        #endif
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()
        let prefsItem = menu.addItem(
            withTitle: "Preferences...",
            action: #selector(StatusBarManager.openPreferences),
            keyEquivalent: ""
        )
        prefsItem.target = statusBarManager

        return menu
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep running even if all windows are closed
        false
    }

    func application(_ application: NSApplication, willEncodeRestorableState coder: NSCoder) {
        // Prevent window restoration state from being saved
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        // Disable state restoration for menu bar app
        false
    }
}
