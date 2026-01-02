import Cocoa

// MARK: - Errors

enum LayoutImageError: Error, LocalizedError {

    case layoutNotFound(String)
    case imageNotFound(String)
    case jsonParsingFailed(Error)
    case jsonFileNotFound

    var errorDescription: String? {
        switch self {
        case .layoutNotFound(let layout):
            return "Layout '\(layout)' not found in mapping dictionary"
        case .imageNotFound(let imageName):
            return "Image '\(imageName)' not found in assets"
        case .jsonParsingFailed(let error):
            return "Failed to parse Layout.json: \(error.localizedDescription)"
        case .jsonFileNotFound:
            return "Layout.json file not found in bundle"
        }
    }
}

// MARK: - Protocols
protocol LayoutMappingProvider {

    func imageName(for layout: String) throws -> String
}

protocol ImageCaching {

    func cache(_ image: NSImage, for key: String)
    func cachedImage(for key: String) -> NSImage?
}

protocol ImageRendering {

    func renderImage(_ baseImage: NSImage, size: NSSize, withCapsLock: Bool) -> NSImage
    func renderImageAsync(_ baseImage: NSImage, size: NSSize, withCapsLock: Bool) async -> NSImage
}

// MARK: - Implementations
final class JSONLayoutMappingProvider: LayoutMappingProvider {

    private lazy var layoutDictionary: [String: String] = {
        do {
            return try loadLayoutDictionary()
        } catch {
            assertionFailure("Failed to load layout dictionary: \(error.localizedDescription)")
            return [:]
        }
    }()

    func imageName(for layout: String) throws -> String {
        guard let imageName = layoutDictionary[layout] else {
            throw LayoutImageError.layoutNotFound(layout)
        }

        return imageName
    }

    private func loadLayoutDictionary() throws -> [String: String] {
        guard let filePath = Bundle.main.path(forResource: "Layout", ofType: "json") else {
            throw LayoutImageError.jsonFileNotFound
        }

        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .uncached)
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] else {
                throw LayoutImageError.jsonParsingFailed(NSError(domain: "LayoutImageContainer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"]))
            }
            return jsonDictionary
        } catch {
            throw LayoutImageError.jsonParsingFailed(error)
        }
    }
}

final class NSCacheImageCache: ImageCaching {

    private let cache = NSCache<NSString, NSImage>()

    func cache(_ image: NSImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func cachedImage(for key: String) -> NSImage? {
        cache.object(forKey: key as NSString)
    }
}

final class FlagImageRenderer: ImageRendering, @unchecked Sendable {

    func renderImage(_ baseImage: NSImage, size: NSSize, withCapsLock: Bool) -> NSImage {
        performRender(baseImage, size: size, withCapsLock: withCapsLock)
    }

    func renderImageAsync(_ baseImage: NSImage, size: NSSize, withCapsLock: Bool) async -> NSImage {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let renderedImage = self.performRender(baseImage, size: size, withCapsLock: withCapsLock)
                continuation.resume(returning: renderedImage)
            }
        }
    }

    private func performRender(_ baseImage: NSImage, size: NSSize, withCapsLock: Bool) -> NSImage {
        NSImage(size: size, flipped: false) { rect in
            baseImage.draw(in: rect)

            if withCapsLock {
                self.drawCapsLockIndicator(in: rect, size: size)
            }

            return true
        }
    }

    private func drawCapsLockIndicator(in rect: NSRect, size: NSSize) {
        let capsLockSymbol = "⇪"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: size.height * 0.3),
            .foregroundColor: NSColor.white
        ]
        let attributedString = NSAttributedString(string: capsLockSymbol, attributes: attributes)
        let stringSize = attributedString.size()

        let padding: CGFloat = 2.0
        let x = rect.origin.x + padding
        let y = rect.origin.y + padding

        let backgroundPadding: CGFloat = 1.0
        let backgroundRect = NSRect(
            x: x - backgroundPadding,
            y: y - backgroundPadding,
            width: stringSize.width + 2 * backgroundPadding,
            height: stringSize.height + 2 * backgroundPadding
        )
        let cornerRadius: CGFloat = 4.0
        let backgroundPath = NSBezierPath(roundedRect: backgroundRect, xRadius: cornerRadius, yRadius: cornerRadius)

        NSColor(white: 0, alpha: 0.5).setFill()
        backgroundPath.fill()

        let stringRect = NSRect(x: x, y: y, width: stringSize.width, height: stringSize.height)
        attributedString.draw(in: stringRect)
    }
}
