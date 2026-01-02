//
//  InputSpurces.swift
//  LanguageFlag
//
//  Created by Bohdan Bochkovskyi on 20.07.2021.
//  Copyright © 2021 Bohdan. All rights reserved.
//

import Carbon

extension TISInputSource {

    private func getProperty(_ key: CFString) -> AnyObject? {
        guard let cfType = TISGetInputSourceProperty(self, key) else {
            return nil
        }
        return Unmanaged<AnyObject>.fromOpaque(cfType).takeUnretainedValue()
    }

    var id: String {
        getProperty(kTISPropertyInputSourceID) as? String ?? ""
    }

    var name: String {
        getProperty(kTISPropertyLocalizedName) as? String ?? ""
    }

    var category: String {
        getProperty(kTISPropertyInputSourceCategory) as? String ?? ""
    }

    var isSelectable: Bool {
        getProperty(kTISPropertyInputSourceIsSelectCapable) as? Bool ?? false
    }

    var sourceLanguages: [String] {
        getProperty(kTISPropertyInputSourceLanguages) as? [String] ?? []
    }

    var iconImageURL: URL? {
        getProperty(kTISPropertyIconImageURL) as? URL
    }

    var iconRef: IconRef? {
        guard let cfType = TISGetInputSourceProperty(self, kTISPropertyIconRef) else {
            return nil
        }
        return OpaquePointer(cfType) as IconRef?
    }
}
