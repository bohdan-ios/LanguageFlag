import AppKit
import Carbon

final class CustomImagesViewModel: ObservableObject {

    // MARK: - Variables
    @Published private(set) var layouts: [LayoutEntry] = []
    @Published private(set) var isLoading = false

    private let imageContainer = LayoutImageContainer.shared
    private let imageStore = CustomLayoutImageStore.shared

    // MARK: - Data
    func loadLayouts() {
        isLoading = true

        // TISCreateInputSourceList must run on the main thread (HIToolbox assertion).
        // Collect stable (id, name) pairs here, then load images off-thread.
        let sources = collectSources()

        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }

            let result = self.buildLayoutEntries(from: sources)

            await MainActor.run {
                self.layouts = result
                self.isLoading = false
            }
        }
    }

    /// Must be called on the main thread.
    private func collectSources() -> [(id: String, name: String)] {
        let all = TISCreateInputSourceList(nil, false).takeRetainedValue() as? [TISInputSource] ?? []
        let category = kTISCategoryKeyboardInputSource as String
        var sources: [(id: String, name: String)] = []

        for source in all {
            guard
                source.category == category,
                source.isSelectable
            else {
                continue
            }

            sources.append((id: tisString(source, kTISPropertyInputSourceID),
                            name: tisString(source, kTISPropertyLocalizedName)))
        }

        return sources
    }

    private func tisString(_ source: TISInputSource, _ key: CFString) -> String {
        guard let ptr = TISGetInputSourceProperty(source, key) else { return "" }

        return Unmanaged<AnyObject>.fromOpaque(ptr).takeUnretainedValue() as? String ?? ""
    }

    private func buildLayoutEntries(from sources: [(id: String, name: String)]) -> [LayoutEntry] {
        var result = sources.map { source in
            LayoutEntry(
                id: source.id,
                name: source.name,
                image: imageContainer.getImage(forID: source.id, name: source.name),
                hasCustom: imageStore.hasCustomImage(forID: source.id)
            )
        }

        result.sort { $0.name < $1.name }

        return result
    }

    // MARK: - Actions
    func upload(layoutID: String, layoutName: String) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .tiff, .bmp, .gif, .svg]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.message = "Choose an image for \"\(layoutName)\""

        guard
            panel.runModal() == .OK,
            let url = panel.url,
            let image = NSImage(contentsOf: url)
        else {
            return
        }

        try? imageStore.save(image, forID: layoutID)
        imageContainer.clearCachedImages()
        updateEntry(id: layoutID) {
            $0.image = image
            $0.hasCustom = true
        }
    }

    func reset(layoutID: String) {
        try? imageStore.delete(forID: layoutID)
        imageContainer.clearCachedImages()

        let refreshed = imageContainer.getImage(for: layoutID)
        updateEntry(id: layoutID) {
            $0.image = refreshed
            $0.hasCustom = false
        }
    }

    // MARK: - Private
    private func updateEntry(id: String, transform: (inout LayoutEntry) -> Void) {
        guard let index = layouts.firstIndex(where: { $0.id == id }) else { return }

        transform(&layouts[index])
    }
}

// MARK: - LayoutEntry

extension CustomImagesViewModel {

    struct LayoutEntry: Identifiable {

        let id: String
        let name: String
        var image: NSImage?
        var hasCustom: Bool
    }
}
