//
//  LanguageWindow.swift
//  LanguageFlag
//
//  Created by Bohdan on 19.04.2020.
//  Copyright © 2020 Bohdan. All rights reserved.
//

import Cocoa
import Combine

final class LanguageWindowController: NSWindowController {

    // MARK: - Variables
    var screenRect: NSRect?

    private var hideTask: Task<Void, Never>?

    private let preferences = UserPreferences.shared

    private let positionCalculator = WindowPositionCalculator()
    private let animationCoordinator = AnimationCoordinator()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Life cycle
    override func windowDidLoad() {
        super.windowDidLoad()

        configureWindow()
        configureContentViewController()
        addObservers()
        observePreferencesChanges()
        updateWindowFrame()
    }

    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
        hideTask?.cancel()
        cancellables.removeAll()
    }

    // MARK: - Public Methods

    /// Shows a preview of the window with current preferences
    func showPreview(force: Bool = false) {
        hideTask?.cancel()
        runShowWindowAnimation(force: force)
        scheduleHide()
    }

    /// Updates the window frame based on the current screenRect
    func updateWindowFrameIfNeeded() {
        updateWindowFrame()
    }
}

// MARK: - Actions
private extension LanguageWindowController {

    @objc
    func keyboardLayoutChanged(notification: NSNotification) {
        hideTask?.cancel()
        runShowWindowAnimation(force: false)
        scheduleHide()
    }

    @objc
    func capsLockChanged(notification: NSNotification) {
        guard notification.object is Bool else { return }

        hideTask?.cancel()
        runShowWindowAnimation(force: false)
        scheduleHide()
    }
}

// MARK: - Configuration
private extension LanguageWindowController {

    func configureWindow() {
        guard screenRect != nil else {
            print("❌ No screen rect provided")
            return
        }
        let win = LanguageWindow(contentRect: .zero)
        win.setAccessibilityIdentifier("LanguageIndicatorWindow")
        window = win
    }

    func configureContentViewController() {
        let flagVC = LanguageViewController()
        window?.contentViewController = flagVC

        let cornerRadius: CGFloat = 16
        [window?.contentView, window?.contentView?.superview].forEach {
            $0?.wantsLayer = true
            $0?.layer?.cornerRadius = cornerRadius
        }
    }

    func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardLayoutChanged),
            name: .keyboardLayoutChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(capsLockChanged),
            name: .capsLockChanged,
            object: nil
        )
    }

    func observePreferencesChanges() {
        preferences.$opacity
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newOpacity in
                self?.window?.alphaValue = CGFloat(newOpacity)
            }
            .store(in: &cancellables)

        preferences.$animationDuration
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.restartAnimation()
            }
            .store(in: &cancellables)
        
        // NEW: Observe animation style changes and show preview unconditionally (forced)
        preferences.$animationStyle
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.showPreview(force: true)
            }
            .store(in: &cancellables)
        
        // NEW: Observe window size changes and update frame + preview
        preferences.$windowSize
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateWindowFrame()
                self?.showPreview()
            }
            .store(in: &cancellables)
        
        // NEW: Observe display position changes and update frame + preview
        preferences.$displayPosition
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateWindowFrame()
                self?.showPreview()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Window Management
private extension LanguageWindowController {

    func updateWindowFrame() {
        guard
            let targetRect = screenRect,
            let window = window
        else {
            return
        }

        let newRect = positionCalculator.calculateWindowFrame(
            in: targetRect,
            position: preferences.displayPosition,
            size: preferences.windowSize
        )

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            context.allowsImplicitAnimation = true
            window.animator().setFrame(newRect, display: true)
        }
    }

    func scheduleHide() {
        let nanoseconds = UInt64(preferences.displayDuration * 1_000_000_000)
        let animationNanoseconds = UInt64((preferences.animationDuration + 0.1) * 1_000_000_000)

        hideTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await Task.sleep(nanoseconds: nanoseconds)
            } catch {
                return
            }

            runHideWindowAnimation()

            // After the animation finishes, remove the window from screen so it
            // disappears from the accessibility tree (needed for UI tests and to
            // prevent hover effects on invisible borderless windows).
            do {
                try await Task.sleep(nanoseconds: animationNanoseconds)
            } catch {
                return
            }

            window?.orderOut(nil)
        }
    }

    func restartAnimation() {
        guard
            let window = window,
            window.alphaValue > 0
        else {
            return
        }

        runHideWindowAnimation()

        Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms
            } catch {
                return
            }

            self?.showPreview()
        }
    }
}

// MARK: - Animation Dispatch
private extension LanguageWindowController {

    func runShowWindowAnimation(force: Bool = false) {
        guard
            let window = window,
            let screenRect = screenRect
        else {
            return
        }

        animationCoordinator.animateIn(
            window: window,
            style: preferences.animationStyle,
            duration: preferences.animationDuration,
            screenRect: screenRect,
            force: force
        )
    }

    func runHideWindowAnimation() {
        guard
            let window = window,
            let screenRect = screenRect
        else {
            return
        }

        animationCoordinator.animateOut(
            window: window,
            style: preferences.animationStyle,
            duration: preferences.animationDuration,
            screenRect: screenRect
        )
    }
}
