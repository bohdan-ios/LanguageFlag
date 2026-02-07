//
//  AppDelegate.swift
//  LanguageFlag
//
//  Created by Bohdan on 18.04.2020.
//  Copyright © 2020 Bohdan. All rights reserved.
//

import Cocoa
import LaunchAtLogin
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Variables
    private var statusBarManager: StatusBarManager?
    private let screenManager: ScreenManager
    private let notificationManager: NotificationManager

    // MARK: - Initialization
    override init() {
        self.screenManager = ScreenManager()
        self.notificationManager = NotificationManager()

        super.init()
    }

    // MARK: - Life cycle
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarManager = StatusBarManager()

        // Disable window restoration for menu bar app
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")

        // Hide dock icon (menu bar app only)
        NSApp.setActivationPolicy(.accessory)
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
