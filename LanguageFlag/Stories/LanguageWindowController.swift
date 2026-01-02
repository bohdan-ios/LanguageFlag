//
//  LanguageWindow.swift
//  LanguageFlag
//
//  Created by Bohdan on 19.04.2020.
//  Copyright © 2020 Bohdan. All rights reserved.
//

import Cocoa
import Combine

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
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Life cycle
    override func windowDidLoad() {
        super.windowDidLoad()

        configureWindow()
        configureContentViewController()
        addObserver()
        observePreferencesChanges()
    }

    // MARK: - Deinit
    deinit {
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
        // 1. Determine the screen reliably
        // If 'main' is nil (common at launch), use the first available screen.
        let targetScreen = NSScreen.main ?? NSScreen.screens.first
        
        guard let currentScreen = targetScreen else {
            print("❌ No screen found")
            return
        }
        
        // 2. Create the window instance (start with a zero rect, we will update it immediately)
        // We initialize with .zero because updateWindowFrame will do the math.
        window = LanguageWindow(contentRect: .zero)
        
        // 3. Force an immediate update to set the correct frame
        updateWindowFrame()
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

    private func observePreferencesChanges() {
        // Observe opacity changes
        preferences.$opacity
            .dropFirst() // Skip initial value
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newOpacity in
                self?.window?.alphaValue = CGFloat(newOpacity)
            }
            .store(in: &cancellables)

        // Observe window size changes
        preferences.$windowSize
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateWindowFrame()
            }
            .store(in: &cancellables)

        // Observe display position changes
        preferences.$displayPosition
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateWindowFrame()
            }
            .store(in: &cancellables)

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
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }

        let visibleFrame = screen.visibleFrame
        
        let rect = createRect(in: visibleFrame)
        
        // Set the frame.
        // Note: animate: false for the first setup to prevent visual jumping
        let shouldAnimate = window?.isVisible ?? false
        window?.setFrame(rect, display: true, animate: shouldAnimate)
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
