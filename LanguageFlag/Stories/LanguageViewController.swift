//
//  ViewController.swift
//  LanguageFlag
//
//  Created by Bohdan on 18.04.2020.
//  Copyright © 2020 Bohdan. All rights reserved.
//

import Carbon
import Cocoa

class LanguageViewController: NSViewController {

    // MARK: - Variables
    static let height: CGFloat = 155
    static let width: CGFloat = 250
    private let layoutImageContainer = LayoutImageContainer.shared
    private var previousModel: KeyboardLayoutNotification?

    // MARK: - UI Components
    private let visualEffectView: NSVisualEffectView = {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.material = .toolTip
        view.state = .active
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let bigLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = .systemFont(ofSize: 21)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.cell?.wraps = true
        return label
    }()

    private let flagImageView: NSImageView = {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let languageNameLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = .systemFont(ofSize: 16)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
    }

    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Actions
extension LanguageViewController {

    @objc
    private func keyboardLayoutChanged(notification: NSNotification) {
        guard let model = notification.object as? KeyboardLayoutNotification else { return }

        previousModel = model
        changeFlagImage(keyboardLayout: model.keyboardLayout,
                        isCapsLockEnabled: model.isCapsLockEnabled,
                        iconRef: model.iconRef)
    }
    
    @objc
    private func capsLockChanged(notification: NSNotification) {
        guard
            let newBool = notification.object as? Bool,
            let previousModel
        else {
            return
        }
        
        changeFlagImage(keyboardLayout: previousModel.keyboardLayout,
                        isCapsLockEnabled: newBool,
                        iconRef: previousModel.iconRef)
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
        NSLayoutConstraint.activate([
            // Visual effect view fills the entire view
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.widthAnchor.constraint(equalToConstant: Self.width),
            visualEffectView.heightAnchor.constraint(equalToConstant: Self.height),

            // Flag image at the top
            flagImageView.centerXAnchor.constraint(equalTo: visualEffectView.centerXAnchor),
            flagImageView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            flagImageView.widthAnchor.constraint(equalToConstant: 230),
            flagImageView.widthAnchor.constraint(equalTo: flagImageView.heightAnchor, multiplier: 16.0 / 9.0),

            // Big label in the center
            bigLabel.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor),
            bigLabel.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: 16),
            bigLabel.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -16),

            // Language name label below flag image
            languageNameLabel.centerXAnchor.constraint(equalTo: visualEffectView.centerXAnchor),
            languageNameLabel.topAnchor.constraint(equalTo: flagImageView.bottomAnchor, constant: -6),

            // View size constraints
            view.heightAnchor.constraint(equalToConstant: Self.height),
            view.widthAnchor.constraint(equalToConstant: Self.width),
        ])
    }

    private func setupUI() {
        let currentLayout = TISCopyCurrentKeyboardInputSource().takeUnretainedValue()
        let model = KeyboardLayoutNotification(keyboardLayout: currentLayout.name,
                                               isCapsLockEnabled: false,
                                               iconRef: currentLayout.iconRef)

        changeFlagImage(keyboardLayout: model.keyboardLayout,
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
}

// MARK: - Image Updates
extension LanguageViewController {

    private func changeFlagImage(keyboardLayout: String,
                                 isCapsLockEnabled: Bool,
                                 iconRef: IconRef?) {
        let languageText = isCapsLockEnabled ? "⇪ " + keyboardLayout : keyboardLayout

        guard let image = layoutImageContainer.getImage(for: keyboardLayout) else {
            tryToSetImage(with: iconRef, languageText: languageText)
            return
        }

        set(bigLabelText: "", flagImage: image, languageLabelText: languageText)
    }

    private func tryToSetImage(with iconRef: IconRef?,
                               languageText: String) {
        guard let iconRef else {
            set(bigLabelText: languageText, flagImage: nil, languageLabelText: "")
            return
        }

        let image = NSImage(iconRef: iconRef)
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
