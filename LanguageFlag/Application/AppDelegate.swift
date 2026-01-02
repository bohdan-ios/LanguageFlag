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
    }
}
