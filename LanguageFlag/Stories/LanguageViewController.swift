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

    // MARK: - IBOutlets
    @IBOutlet private weak var bigLabel: NSTextField!
    @IBOutlet private weak var flagImageView: NSImageView!
    @IBOutlet private weak var languageNameLabel: NSTextField!

    // MARK: - Life cycle
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

// MARK: - Private
extension LanguageViewController {

    private func setupUI() {
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: Self.height),
            view.widthAnchor.constraint(equalToConstant: Self.width),
        ])

        bigLabel.cell?.wraps = true
        
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
