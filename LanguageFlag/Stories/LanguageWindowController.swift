//
//  LanguageWindow.swift
//  LanguageFlag
//
//  Created by Bohdan on 19.04.2020.
//  Copyright © 2020 Bohdan. All rights reserved.
//

import Cocoa

@propertyWrapper
struct ScheduledTimer {

    private var timer: Timer?

    var wrappedValue: Timer? {
        get { timer }
        set {
            timer?.invalidate()
            timer = newValue
            if let newValue {
                RunLoop.main.add(newValue, forMode: .common)
            }
        }
    }

    mutating func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}

final class LanguageWindowController: NSWindowController {

    // MARK: - Variables
    var screenRect: NSRect?
    @ScheduledTimer private var timer: Timer?

    // MARK: - Life cycle
    override func windowDidLoad() {
        super.windowDidLoad()
        configureWindow()
        configureContentViewController()
        addObserver()
    }
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Actions
extension LanguageWindowController {

    @objc
    private func keyboardLayoutChanged(notification: NSNotification) {
        timer?.invalidate()
        runShowWindowAnimation()
        scheduleTimer()
    }

    @objc
    private func capsLockChanged(notification: NSNotification) {
        timer?.invalidate()
        runShowWindowAnimation()
        scheduleTimer()
    }

    @objc
    private func hideApplication() {
        timer?.invalidate()
        runHideWindowAnimation()
    }
}

// MARK: - Configure
extension LanguageWindowController {

    private func configureWindow() {
        guard let screenRect = screenRect ?? NSScreen.main?.visibleFrame else { return }

        let rect = createRect(in: screenRect)
        window = LanguageWindow(contentRect: rect)
        window?.setFrame(rect, display: true)
    }

    private func createRect(in screen: CGRect) -> CGRect {
        let posX: CGFloat = screen.minX + (screen.width - LanguageViewController.width) / 2
        let posY: CGFloat = screen.minY + (screen.height * 0.25)
        let rect = NSRect(x: posX,
                          y: posY,
                          width: LanguageViewController.width,
                          height: LanguageViewController.height)

        return rect
    }

    private func configureContentViewController() {
        let flagVC = LanguageViewController()

        window?.contentViewController = flagVC
        let cornerRadius: CGFloat = 16
        [window?.contentView, window?.contentView?.superview].forEach {
            $0?.wantsLayer = true
            $0?.layer?.cornerRadius = cornerRadius
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardLayoutChanged),
                                               name: .keyboardLayoutChanged,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(capsLockChanged),
                                               name: .capsLockChanged,
                                               object: nil)
    }
    
    private func scheduleTimer() {
        timer = Timer(
            timeInterval: 1,
            target: self,
            selector: #selector(hideApplication),
            userInfo: nil,
            repeats: false)
    }
    
    private func runShowWindowAnimation() {
        window?.fadeIn(duration: 0.3)
    }

    private func runHideWindowAnimation() {
        window?.fadeOut(duration: 0.4)
    }
}
