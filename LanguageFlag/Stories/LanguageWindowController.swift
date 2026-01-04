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

        // Use percentage-based padding for better multi-monitor support
        let horizontalPadding = min(50, screen.width * 0.05) // 5% or 50px, whichever is smaller
        let verticalPadding = min(50, screen.height * 0.05)   // 5% or 50px, whichever is smaller

        // Calculate X position
        switch position {
        case .topLeft, .centerLeft, .bottomLeft:
            x = screen.minX + horizontalPadding
        case .topCenter, .center, .bottomCenter:
            x = screen.minX + (screen.width - size.width) / 2
        case .topRight, .centerRight, .bottomRight:
            x = screen.maxX - size.width - horizontalPadding
        }

        // Calculate Y position
        switch position {
        case .topLeft, .topCenter, .topRight:
            y = screen.maxY - size.height - verticalPadding
        case .centerLeft, .center, .centerRight:
            y = screen.minY + (screen.height - size.height) / 2
        case .bottomLeft, .bottomCenter, .bottomRight:
            y = screen.minY + verticalPadding
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

        // For certain animations, we need to ensure the window frame is set
        // to the correct target position before the animation starts
        let needsFrameSetup: [AnimationStyle] = [.slide, .scale, .pixelate, .bounce, .flip, .swing, .elastic, .hologram, .energyPortal, .digitalMaterialize, .liquidRipple, .inkDiffusion, .vhsGlitch]
        if needsFrameSetup.contains(preferences.animationStyle) {
            guard let targetRect = screenRect, let window = window else { return }
            let targetFrame = createRect(in: targetRect)

            // Store the target frame temporarily
            window.setFrame(targetFrame, display: false, animate: false)
        }

        switch preferences.animationStyle {
        case .fade:
            window?.fadeIn(duration: duration)
        case .slide:
            let direction = getSlideDirection()
            let maxDistance = getMaxSlideDistance(for: direction)
            window?.slideIn(duration: duration, direction: direction, maxDistance: maxDistance)
        case .scale:
            window?.scaleIn(duration: duration)
        case .pixelate:
            window?.pixelateIn(duration: duration)
        case .blur:
            window?.blurIn(duration: duration)
        case .flip:
            window?.flipIn(duration: duration)
        case .bounce:
            window?.bounceIn(duration: duration)
        case .hologram:
            window?.hologramIn(duration: duration)
        case .rotate:
            window?.rotateIn(duration: duration)
        case .swing:
            window?.swingIn(duration: duration)
        case .elastic:
            window?.elasticIn(duration: duration)
        case .energyPortal:
            window?.energyPortalIn(duration: duration)
        case .digitalMaterialize:
            window?.digitalMaterializeIn(duration: duration)
        case .liquidRipple:
            window?.liquidRippleIn(duration: duration)
        case .inkDiffusion:
            window?.inkDiffusionIn(duration: duration)
        case .vhsGlitch:
            window?.vhsGlitchIn(duration: duration)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func runHideWindowAnimation() {
        let duration = preferences.animationDuration

        switch preferences.animationStyle {
        case .fade:
            window?.fadeOut(duration: duration)
        case .slide:
            let direction = getSlideDirection()
            let maxDistance = getMaxSlideDistance(for: direction)
            window?.slideOut(duration: duration, direction: direction, maxDistance: maxDistance) { [weak self] in
                // After slide out completes, reset window to correct position and hide it
                guard let self = self, let targetRect = self.screenRect else { return }
                let targetFrame = self.createRect(in: targetRect)
                self.window?.setFrame(targetFrame, display: false, animate: false)
                self.window?.orderOut(nil)
            }
        case .scale:
            window?.scaleOut(duration: duration) { [weak self] in
                // After scale out completes, reset window to correct position and hide it
                guard let self = self, let targetRect = self.screenRect else { return }
                let targetFrame = self.createRect(in: targetRect)
                self.window?.setFrame(targetFrame, display: false, animate: false)
                self.window?.orderOut(nil)
            }
        case .pixelate:
            window?.pixelateOut(duration: duration) { [weak self] in
                // After pixelate out completes, reset window to correct position and hide it
                guard let self = self, let targetRect = self.screenRect else { return }
                let targetFrame = self.createRect(in: targetRect)
                self.window?.setFrame(targetFrame, display: false, animate: false)
                self.window?.orderOut(nil)
            }
        case .blur:
            window?.blurOut(duration: duration)
        case .flip:
            window?.flipOut(duration: duration) { [weak self] in
                // After flip out completes, reset window to correct position and hide it
                guard let self = self, let targetRect = self.screenRect else { return }
                let targetFrame = self.createRect(in: targetRect)
                self.window?.setFrame(targetFrame, display: false, animate: false)
                self.window?.orderOut(nil)
            }
        case .bounce:
            window?.bounceOut(duration: duration) { [weak self] in
                // After bounce out completes, reset window to correct position and hide it
                guard let self = self, let targetRect = self.screenRect else { return }
                let targetFrame = self.createRect(in: targetRect)
                self.window?.setFrame(targetFrame, display: false, animate: false)
                self.window?.orderOut(nil)
            }
        case .rotate:
            window?.rotateOut(duration: duration)
        case .swing:
            window?.swingOut(duration: duration) { [weak self] in
                // After swing out completes, reset window to correct position and hide it
                guard let self = self, let targetRect = self.screenRect else { return }
                let targetFrame = self.createRect(in: targetRect)
                self.window?.setFrame(targetFrame, display: false, animate: false)
                self.window?.orderOut(nil)
            }
        case .elastic:
            window?.elasticOut(duration: duration)
        case .hologram:
            window?.hologramOut(duration: duration) { [weak self] in
                guard let self = self, let targetRect = self.screenRect else { return }
                let targetFrame = self.createRect(in: targetRect)
                self.window?.setFrame(targetFrame, display: false, animate: false)
                self.window?.orderOut(nil)
            }
        case .energyPortal:
            window?.energyPortalOut(duration: duration) { [weak self] in
                guard let self = self, let targetRect = self.screenRect else { return }
                let targetFrame = self.createRect(in: targetRect)
                self.window?.setFrame(targetFrame, display: false, animate: false)
                self.window?.orderOut(nil)
            }
        case .digitalMaterialize:
            window?.digitalMaterializeOut(duration: duration) { [weak self] in
                guard let self = self, let targetRect = self.screenRect else { return }
                let targetFrame = self.createRect(in: targetRect)
                self.window?.setFrame(targetFrame, display: false, animate: false)
                self.window?.orderOut(nil)
            }
        case .liquidRipple:
            window?.liquidRippleOut(duration: duration) { [weak self] in
                guard let self = self, let targetRect = self.screenRect else { return }
                let targetFrame = self.createRect(in: targetRect)
                self.window?.setFrame(targetFrame, display: false, animate: false)
                self.window?.orderOut(nil)
            }
        case .inkDiffusion:
            window?.inkDiffusionOut(duration: duration) { [weak self] in
                guard let self = self, let targetRect = self.screenRect else { return }
                let targetFrame = self.createRect(in: targetRect)
                self.window?.setFrame(targetFrame, display: false, animate: false)
                self.window?.orderOut(nil)
            }
        case .vhsGlitch:
            window?.vhsGlitchOut(duration: duration) { [weak self] in
                guard let self = self, let targetRect = self.screenRect else { return }
                let targetFrame = self.createRect(in: targetRect)
                self.window?.setFrame(targetFrame, display: false, animate: false)
                self.window?.orderOut(nil)
            }
        }
    }

    /// Determines the slide direction based on the window's position relative to screen edges
    /// Windows slide towards the nearest edge to avoid appearing on adjacent monitors
    private func getSlideDirection() -> SlideDirection {
        guard let screenRect = screenRect, let window = window else {
            return .down // Default fallback
        }

        let windowFrame = window.frame

        // Calculate distances to each edge
        let distanceToTop = screenRect.maxY - windowFrame.maxY
        let distanceToBottom = windowFrame.minY - screenRect.minY
        let distanceToLeft = windowFrame.minX - screenRect.minX
        let distanceToRight = screenRect.maxX - windowFrame.maxX

        // Find the minimum distance
        let minDistance = min(distanceToTop, distanceToBottom, distanceToLeft, distanceToRight)

        // Slide towards the nearest edge
        if minDistance == distanceToTop {
            return .up
        } else if minDistance == distanceToBottom {
            return .down
        } else if minDistance == distanceToLeft {
            return .left
        } else {
            return .right
        }
    }

    /// Calculates the maximum slide distance to prevent window from appearing on adjacent monitors
    /// Uses min(distance to edge, window dimension) to stay within screen bounds
    /// Adds a small extra distance only if there's enough space
    private func getMaxSlideDistance(for direction: SlideDirection) -> CGFloat {
        guard let screenRect = screenRect, let window = window else {
            return 0
        }

        let windowFrame = window.frame

        switch direction {
        case .up:
            let distanceToEdge = screenRect.maxY - windowFrame.maxY
            let baseDistance = min(distanceToEdge, windowFrame.height)
            // Add extra distance only if we have room beyond the window height
            let extraDistance = max(0, distanceToEdge - windowFrame.height)
            return baseDistance + min(extraDistance, 50)
        case .down:
            let distanceToEdge = windowFrame.minY - screenRect.minY
            let baseDistance = min(distanceToEdge, windowFrame.height)
            let extraDistance = max(0, distanceToEdge - windowFrame.height)
            return baseDistance + min(extraDistance, 50)
        case .left:
            let distanceToEdge = windowFrame.minX - screenRect.minX
            let baseDistance = min(distanceToEdge, windowFrame.width)
            let extraDistance = max(0, distanceToEdge - windowFrame.width)
            return baseDistance + min(extraDistance, 50)
        case .right:
            let distanceToEdge = screenRect.maxX - windowFrame.maxX
            let baseDistance = min(distanceToEdge, windowFrame.width)
            let extraDistance = max(0, distanceToEdge - windowFrame.width)
            return baseDistance + min(extraDistance, 50)
        }
    }
}
