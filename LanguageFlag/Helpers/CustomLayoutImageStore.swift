import AppKit

private extension NSImage {

    func resizedToMax(dimension maxDim: CGFloat) -> NSImage {
        let longest = max(size.width, size.height)
        guard longest > maxDim else { return self }

        let scale = maxDim / longest
        let newSize = NSSize(width: (size.width * scale).rounded(), height: (size.height * scale).rounded())

        return NSImage(size: newSize, flipped: false) { rect in
            self.draw(in: rect)
            return true
        }
    }
}

/// Persists user-supplied flag images in ~/Library/Application Support/LanguageFlag/CustomImages/
/// Each image is keyed by the TISInputSource ID (e.g. com.apple.keylayout.Russian).
final class CustomLayoutImageStore {

    static let shared = CustomLayoutImageStore()

    private let directory: URL

    private init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
        directory = appSupport.appendingPathComponent("LanguageFlag/CustomImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    // MARK: - Public API

    /// Maximum pixel dimension stored for a custom image (2× the largest display size).
    private static let maxStoredDimension: CGFloat = 512

    func save(_ image: NSImage, forID layoutID: String) throws {
        let resized = image.resizedToMax(dimension: Self.maxStoredDimension)
        guard
            let tiff = resized.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff),
            let png = bitmap.representation(using: .png, properties: [:])
        else {
            throw StoreError.encodingFailed
        }
        try png.write(to: fileURL(for: layoutID))
    }

    func image(forID layoutID: String) -> NSImage? {
        NSImage(contentsOf: fileURL(for: layoutID))
    }

    func delete(forID layoutID: String) throws {
        let url = fileURL(for: layoutID)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }

    func hasCustomImage(forID layoutID: String) -> Bool {
        FileManager.default.fileExists(atPath: fileURL(for: layoutID).path)
    }

    // MARK: - Private

    private func fileURL(for layoutID: String) -> URL {
        let safe = layoutID.replacingOccurrences(of: "/", with: "_")
        return directory.appendingPathComponent(safe + ".png")
    }

    // MARK: - Errors

    enum StoreError: LocalizedError {

        case encodingFailed

        var errorDescription: String? {
            "Failed to encode image as PNG."
        }
    }
}
