//
//  KeyboardLayoutNotification.swift
//  LanguageFlag
//
//  Created by Bohdan Bochkovskyi on 01.03.2023.
//  Copyright © 2023 Bohdan. All rights reserved.
//

import Foundation

struct KeyboardLayoutNotification {

    let keyboardLayout: String
    let keyboardLayoutID: String
    let isCapsLockEnabled: Bool
    let iconRef: IconRef?
}
