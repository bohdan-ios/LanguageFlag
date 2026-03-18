//
//  ViewController.swift
//  LanguageFlag
//
//  Created by Bohdan on 18.04.2020.
//  Copyright © 2020 Bohdan. All rights reserved.
//

import Carbon
import Cocoa
import Combine
import UniformTypeIdentifiers

class LanguageViewController: NSViewController {

    // MARK: - Variables
    private let layoutImageContainer = LayoutImageContainer.shared
    private var previousModel: KeyboardLayoutNotification?
    private let preferences = UserPreferences.shared
    private var cancellables = Set<AnyCancellable>()

    // Size constraints that need to be updated
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    private var visualEffectWidthConstraint: NSLayoutConstraint?
    private var visualEffectHeightConstraint: NSLayoutConstraint?
    private var flagImageBottomConstraint: NSLayoutConstraint?

    // MARK: - UI Components
    private let visualEffectView: NSVisualEffectView = {
        let view = NSVisualEffectView()
        view.blendingMode = .withinWindow
        view.material = .toolTip
        view.state = .active
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private let bigLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = .systemFont(ofSize: UserPreferences.shared.windowSize.fontSizes.title)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.cell?.wraps = true
        label.setAccessibilityIdentifier("bigLabel")

        return label
    }()

    private let flagImageView: NSImageView = {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let languageNameLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = .systemFont(ofSize: UserPreferences.shared.windowSize.fontSizes.label)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setAccessibilityIdentifier("languageNameLabel")

        return label
    }()

    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        setupViewHierarchy()
        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addObserver()
        observePreferencesChanges()
    }

    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
        cancellables.removeAll()
    }
}

// MARK: - Actions
extension LanguageViewController {

    @objc
    private func keyboardLayoutChanged(notification: NSNotification) {
        guard let model = notification.object as? KeyboardLayoutNotification else { return }

        previousModel = model
        changeFlagImage(keyboardLayout: model.keyboardLayout,
                        keyboardLayoutID: model.keyboardLayoutID,
                        isCapsLockEnabled: model.isCapsLockEnabled,
                        iconRef: model.iconRef)
    }
    
    @objc
    private func capsLockChanged(notification: NSNotification) {
        guard let newBool = notification.object as? Bool else { return }

        let layout: TISInputSource
        if let previous = previousModel {
            changeFlagImage(keyboardLayout: previous.keyboardLayout,
                            keyboardLayoutID: previous.keyboardLayoutID,
                            isCapsLockEnabled: newBool,
                            iconRef: previous.iconRef)
        } else {
            // No layout change has occurred yet — use the current system layout
            layout = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
            changeFlagImage(keyboardLayout: layout.name,
                            keyboardLayoutID: layout.id,
                            isCapsLockEnabled: newBool,
                            iconRef: layout.iconRef)
        }
    }
}

// MARK: - Setup
extension LanguageViewController {

    private func setupViewHierarchy() {
        view.addSubview(visualEffectView)
        visualEffectView.addSubview(flagImageView)
        visualEffectView.addSubview(bigLabel)
        visualEffectView.addSubview(languageNameLabel)
    }

    private func setupConstraints() {
        let dimensions = preferences.windowSize.dimensions

        // Create size constraints and store references
        visualEffectWidthConstraint = visualEffectView.widthAnchor.constraint(equalToConstant: dimensions.width)
        visualEffectHeightConstraint = visualEffectView.heightAnchor.constraint(equalToConstant: dimensions.height)
        widthConstraint = view.widthAnchor.constraint(equalToConstant: dimensions.width)
        heightConstraint = view.heightAnchor.constraint(equalToConstant: dimensions.height)
        flagImageBottomConstraint = flagImageView.bottomAnchor.constraint(
            equalTo: visualEffectView.bottomAnchor,
            constant: -labelAreaHeight(for: preferences.windowSize.fontSizes.label)
        )

        guard
            let visualEffectWidthConstraint,
            let visualEffectHeightConstraint,
            let flagImageBottomConstraint,
            let heightConstraint,
            let widthConstraint
        else {
            return
        }

        NSLayoutConstraint.activate([
            // Visual effect view fills the entire view
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectWidthConstraint,
            visualEffectHeightConstraint,

            // Flag image: 16px inset on all sides, height fills remaining space above label
            flagImageView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: 16),
            flagImageView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -16),
            flagImageView.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: 16),
            flagImageBottomConstraint,

            // Big label in the center
            bigLabel.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor),
            bigLabel.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: 16),
            bigLabel.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -16),

            // Language name label: 16px from bottom, no chain to flag needed
            languageNameLabel.centerXAnchor.constraint(equalTo: visualEffectView.centerXAnchor),
            languageNameLabel.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor, constant: -16),

            // View size constraints
            heightConstraint,
            widthConstraint,
        ])
    }

    private func setupUI() {
        let currentLayout = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        let model = KeyboardLayoutNotification(keyboardLayout: currentLayout.name,
                                               keyboardLayoutID: currentLayout.id,
                                               isCapsLockEnabled: false,
                                               iconRef: currentLayout.iconRef)

        changeFlagImage(keyboardLayout: model.keyboardLayout,
                        keyboardLayoutID: model.keyboardLayoutID,
                        isCapsLockEnabled: model.isCapsLockEnabled,
                        iconRef: model.iconRef)
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
        preferences.$windowSize
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSize in
                self?.updateViewSize(to: newSize)
            }
            .store(in: &cancellables)
    }

    /// Returns the total height to reserve below the flag: 16px gap + label line height + 16px bottom padding.
    private func labelAreaHeight(for fontSize: CGFloat) -> CGFloat {
        let font = NSFont.systemFont(ofSize: fontSize)
        let lineHeight = ceil(font.ascender - font.descender)

        return 16 + lineHeight + 16
    }

    private func updateViewSize(to size: WindowSize) {
        let dimensions = size.dimensions
        let fontSizes = size.fontSizes

        // Update constraints
        widthConstraint?.constant = dimensions.width
        heightConstraint?.constant = dimensions.height
        visualEffectWidthConstraint?.constant = dimensions.width
        visualEffectHeightConstraint?.constant = dimensions.height
        flagImageBottomConstraint?.constant = -labelAreaHeight(for: fontSizes.label)

        // Update fonts
        bigLabel.font = .systemFont(ofSize: fontSizes.title)
        languageNameLabel.font = .systemFont(ofSize: fontSizes.label)

        view.layoutSubtreeIfNeeded()
    }
}

// MARK: - Image Updates
extension LanguageViewController {

    private func changeFlagImage(keyboardLayout: String,
                                 keyboardLayoutID: String,
                                 isCapsLockEnabled: Bool,
                                 iconRef: IconRef?) {
        let languageText = (isCapsLockEnabled && preferences.showCapsLockIndicator) ? "⇪ " + keyboardLayout : keyboardLayout

        guard let image = layoutImageContainer.getImage(forID: keyboardLayoutID, name: keyboardLayout) else {
            tryToSetImage(with: iconRef, languageText: languageText)
            return
        }

        set(bigLabelText: "", flagImage: image, languageLabelText: languageText)
    }

    private func tryToSetImage(with iconRef: IconRef?,
                               languageText: String) {
        guard iconRef != nil else {
            set(bigLabelText: languageText, flagImage: nil, languageLabelText: "")
            return
        }

        // Try to get the keyboard icon from the system
        let image = NSWorkspace.shared.icon(for: UTType.text)
        set(bigLabelText: "", flagImage: image, languageLabelText: languageText)
    }
    
    private func set(bigLabelText: String,
                     flagImage: NSImage?,
                     languageLabelText: String) {
        bigLabel.stringValue = bigLabelText
        flagImageView.image = flagImage
        languageNameLabel.stringValue = languageLabelText
    }
}
