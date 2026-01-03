//
//  LanguageWindow.swift
//  LanguageFlag
//
//  Created by Bohdan on 19.04.2020.
//  Copyright © 2020 Bohdan. All rights reserved.
//

import Cocoa
import Combine
import Carbon

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
    private let preferences = UserPreferences.shared
    private let analytics = LayoutAnalytics.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Life cycle
    override func windowDidLoad() {
        super.windowDidLoad()

        configureWindow()
        configureContentViewController()
        addObserver()
        observePreferencesChanges()
        initializeAnalytics()

        // Set the correct frame after everything is configured
        updateWindowFrame()
    }

    // MARK: - Deinit
    deinit {
        analytics.stopTracking()
        NotificationCenter.default.removeObserver(self)
        cancellables.removeAll()
    }

    // MARK: - Public Methods
    /// Shows a preview of the window with current preferences
    func showPreview() {
        timer?.invalidate()
        runShowWindowAnimation()
        scheduleTimer()
    }

    /// Updates the window frame based on the current screenRect
    /// Called when screen parameters change (e.g., Dock moves to another screen)
    func updateWindowFrameIfNeeded() {
        updateWindowFrame()
    }
}

// MARK: - Actions
extension LanguageWindowController {

    @objc
    private func keyboardLayoutChanged(notification: NSNotification) {
        // Track layout change for analytics
        if let model = notification.object as? KeyboardLayoutNotification {
            analytics.startTracking(layout: model.keyboardLayout)
        }

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
        // 1. Use screenRect if set by ScreenManager, otherwise fall back to main screen
        guard let targetRect = screenRect else {
            print("❌ No screen rect provided")
            return
        }

        // 2. Create the window instance with a zero rect initially
        // We'll set the correct frame after the content view controller is configured
        window = LanguageWindow(contentRect: .zero)
    }

    private func createRect(in screen: CGRect) -> CGRect {
        let dimensions = preferences.windowSize.dimensions
        let position = calculatePosition(for: preferences.displayPosition, in: screen, size: dimensions)

        return NSRect(x: position.x,
                      y: position.y,
                      width: dimensions.width,
                      height: dimensions.height)
    }

    private func calculatePosition(for position: DisplayPosition,
                                   in screen: CGRect,
                                   size: (width: CGFloat, height: CGFloat)) -> (x: CGFloat, y: CGFloat) {
        let x: CGFloat
        let y: CGFloat

        // Calculate X position
        switch position {
        case .topLeft, .centerLeft, .bottomLeft:
            x = screen.minX + 50
        case .topCenter, .center, .bottomCenter:
            x = screen.minX + (screen.width - size.width) / 2
        case .topRight, .centerRight, .bottomRight:
            x = screen.maxX - size.width - 50
        }

        // Calculate Y position
        switch position {
        case .topLeft, .topCenter, .topRight:
            y = screen.maxY - size.height - 50
        case .centerLeft, .center, .centerRight:
            y = screen.minY + (screen.height - size.height) / 2
        case .bottomLeft, .bottomCenter, .bottomRight:
            y = screen.minY + 50
        }

        return (x, y)
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

    private func initializeAnalytics() {
        // Start tracking the current layout
        let currentLayout = TISCopyCurrentKeyboardInputSource().takeUnretainedValue()
        analytics.startTracking(layout: currentLayout.name)
    }

    private func observePreferencesChanges() {
        // Observe opacity changes
        preferences.$opacity
            .dropFirst() // Skip initial value
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newOpacity in
                self?.window?.alphaValue = CGFloat(newOpacity)
            }
            .store(in: &cancellables)

        // Note: Window size and display position changes are now handled centrally
        // by ScreenManager to ensure simultaneous updates across all displays

        // Observe animation duration changes
        preferences.$animationDuration
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.restartAnimation()
            }
            .store(in: &cancellables)
    }

    private func updateWindowFrame() {
        // Use the screenRect that was set by ScreenManager for this specific screen
        guard let targetRect = screenRect else { return }
        guard let window = window else { return }

        let newRect = createRect(in: targetRect)

        // Animate the frame change using Core Animation
        // This works within CATransaction for synchronization across all windows
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            context.allowsImplicitAnimation = true

            window.animator().setFrame(newRect, display: true)
        }
    }

    private func restartAnimation() {
        // If window is currently visible, restart the animation with new duration
        guard let window = window, window.alphaValue > 0 else { return }

        // Hide the window quickly
        runHideWindowAnimation()

        // After a brief delay, show it again with the new animation duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.showPreview()
        }
    }

    private func scheduleTimer() {
        timer = Timer(
            timeInterval: preferences.displayDuration,
            target: self,
            selector: #selector(hideApplication),
            userInfo: nil,
            repeats: false)
    }

    private func runShowWindowAnimation() {
        let duration = preferences.animationDuration

        // Set opacity before animation if window is being shown for first time
        if window?.alphaValue == 0 {
            window?.alphaValue = CGFloat(preferences.opacity)
        }

        switch preferences.animationStyle {
        case .fade:
            window?.fadeIn(duration: duration)
        case .slide:
            window?.slideIn(duration: duration)
        case .scale:
            window?.scaleIn(duration: duration)
        }
    }

    private func runHideWindowAnimation() {
        let duration = preferences.animationDuration

        switch preferences.animationStyle {
        case .fade:
            window?.fadeOut(duration: duration)
        case .slide:
            window?.slideOut(duration: duration)
        case .scale:
            window?.scaleOut(duration: duration)
        }
    }
}
