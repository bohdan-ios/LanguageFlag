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
    func updateWindowFrameIfNeeded() {
        updateWindowFrame()
    }
}

// MARK: - Actions
private extension LanguageWindowController {

    @objc
    func keyboardLayoutChanged(notification: NSNotification) {
        timer?.invalidate()
        runShowWindowAnimation()
        scheduleTimer()
    }

    @objc
    func capsLockChanged(notification: NSNotification) {
        timer?.invalidate()
        runShowWindowAnimation()
        scheduleTimer()
    }

    @objc
    func hideApplication() {
        timer?.invalidate()
        runHideWindowAnimation()
    }
}

// MARK: - Configuration
private extension LanguageWindowController {

    func configureWindow() {
        guard screenRect != nil else {
            print("❌ No screen rect provided")
            return
        }
        window = LanguageWindow(contentRect: .zero)
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

    func scheduleTimer() {
        timer = Timer(
            timeInterval: preferences.displayDuration,
            target: self,
            selector: #selector(hideApplication),
            userInfo: nil,
            repeats: false
        )
    }

    func restartAnimation() {
        guard
            let window = window,
            window.alphaValue > 0
        else {
            return
        }

        runHideWindowAnimation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.showPreview()
        }
    }
}

// MARK: - Animation Dispatch
private extension LanguageWindowController {

    func runShowWindowAnimation() {
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
            screenRect: screenRect
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
