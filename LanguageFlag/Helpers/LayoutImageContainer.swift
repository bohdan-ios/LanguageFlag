//
//  LayoutImageContainer.swift
//  LanguageFlag
//
//  Created by Bohdan Bochkovskyi on 20.07.2021.
//  Copyright © 2021 Bohdan. All rights reserved.
//

import Cocoa
import os.log


final class LayoutImageContainer {

    // MARK: - Properties
    static let shared = LayoutImageContainer()

    private let mappingProvider: LayoutMappingProvider
    private let imageCache: ImageCaching
    private let imageRenderer: ImageRendering

    // MARK: - Initialization
    init(
        mappingProvider: LayoutMappingProvider = JSONLayoutMappingProvider(),
        imageCache: ImageCaching = NSCacheImageCache(),
        imageRenderer: ImageRendering = FlagImageRenderer()
    ) {
        self.mappingProvider = mappingProvider
        self.imageCache = imageCache
        self.imageRenderer = imageRenderer
    }

    // MARK: - Public Methods

    /// Looks up by source ID first (stable), falls back to localized name for entries not yet migrated.
    /// Checks the user's custom image store before bundled assets.
    func getImage(forID layoutID: String,
                  name: String) -> NSImage? {
        CustomLayoutImageStore.shared.image(forID: layoutID)
            ?? getImage(for: layoutID)
            ?? getImage(for: name)
    }

    /// Clears the rendered-image cache. Call after any custom image is saved or deleted.
    func clearCachedImages() {
        imageCache.clearAll()
    }

    func getImage(for keyboardLayout: String) -> NSImage? {
        do {
            let imageName = try mappingProvider.imageName(for: keyboardLayout)

            guard let image = NSImage(named: "Flags/" + imageName) else {
                throw LayoutImageError.imageNotFound(imageName)
            }

            return image
        } catch {
            os_log("Failed to get image for layout %@: %@",
                   log: .default,
                   type: .error,
                   keyboardLayout,
                   error.localizedDescription)

            return nil
        }
    }

    func getFlagItem(forID layoutID: String,
                     name: String,
                     size: NSSize,
                     isCapsLock: Bool = false) -> NSImage? {
        getFlagItem(forID: layoutID, name: name, size: size, isCapsLock: isCapsLock, imageCache: imageCache)
    }

    func getFlagItem(for keyboardLayout: String,
                     size: NSSize) -> NSImage? {
        getFlagItem(for: keyboardLayout, size: size, isCapsLock: false)
    }

    func getFlagItem(for keyboardLayout: String,
                     size: NSSize,
                     isCapsLock: Bool) -> NSImage? {
        let cacheKey = createCacheKey(layout: keyboardLayout, size: size, capsLock: isCapsLock)

        if let cachedImage = imageCache.cachedImage(for: cacheKey) {
            return cachedImage
        }

        guard let baseImage = getImage(for: keyboardLayout) else {
            return nil
        }

        let renderedImage = imageRenderer.renderImage(baseImage, size: size, withCapsLock: isCapsLock)
        imageCache.cache(renderedImage, for: cacheKey)

        return renderedImage
    }

    private func getFlagItem(forID layoutID: String,
                             name: String,
                             size: NSSize,
                             isCapsLock: Bool,
                             imageCache: ImageCaching) -> NSImage? {
        let cacheKey = createCacheKey(layout: layoutID, size: size, capsLock: isCapsLock)

        if let cachedImage = imageCache.cachedImage(for: cacheKey) {
            return cachedImage
        }

        guard let baseImage = getImage(forID: layoutID, name: name) else {
            return nil
        }

        let renderedImage = imageRenderer.renderImage(baseImage, size: size, withCapsLock: isCapsLock)
        imageCache.cache(renderedImage, for: cacheKey)

        return renderedImage
    }

    // MARK: - Async Methods
    func getFlagItemAsync(forID layoutID: String,
                          name: String,
                          size: NSSize,
                          isCapsLock: Bool) async -> NSImage? {
        let cacheKey = createCacheKey(layout: layoutID, size: size, capsLock: isCapsLock)

        if let cachedImage = imageCache.cachedImage(for: cacheKey) {
            return cachedImage
        }

        guard let baseImage = getImage(forID: layoutID, name: name) else {
            return nil
        }

        let renderedImage = await imageRenderer.renderImageAsync(baseImage, size: size, withCapsLock: isCapsLock)
        imageCache.cache(renderedImage, for: cacheKey)

        return renderedImage
    }

    func getFlagItemAsync(for keyboardLayout: String,
                          size: NSSize,
                          isCapsLock: Bool) async -> NSImage? {
        let cacheKey = createCacheKey(layout: keyboardLayout, size: size, capsLock: isCapsLock)

        // Check cache on main thread
        if let cachedImage = imageCache.cachedImage(for: cacheKey) {
            return cachedImage
        }

        // Get base image
        guard let baseImage = getImage(for: keyboardLayout) else {
            return nil
        }

        // Render off main thread
        let renderedImage = await imageRenderer.renderImageAsync(baseImage, size: size, withCapsLock: isCapsLock)

        // Cache the result
        imageCache.cache(renderedImage, for: cacheKey)

        return renderedImage
    }

    // MARK: - Private Methods
    private func createCacheKey(layout: String, size: NSSize, capsLock: Bool) -> String {
        "\(layout)-\(size.width)x\(size.height)-\(capsLock)"
    }
}
