import Cocoa
import Combine

final class LanguageWindow: NSWindow {

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(contentRect: NSRect) {
        super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)

        configureAppearance()
        observePreferences()
    }
    
    // MARK: - Private
    private func configureAppearance() {
        isOpaque = false
        backgroundColor = .clear
        // Use statusBar level to stay above the Dock
        level = .statusBar
    }
    
    private func observePreferences() {
        UserPreferences.shared.$bypassClick
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bypass in
                self?.ignoresMouseEvents = bypass
            }
            .store(in: &cancellables)
    }
}
