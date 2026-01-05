import SwiftUI

/// Shortcuts preferences pane for keyboard shortcut display settings
struct ShortcutsPreferencesPane: View {

    // MARK: - Variables
    @ObservedObject private var preferences: UserPreferences
    
    // MARK: - Init
    init(preferences: UserPreferences) {
        self.preferences = preferences
    }

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Show keyboard shortcuts for current layout", isOn: $preferences.showShortcuts)
                    .help("Display common keyboard shortcuts when switching layouts")

                Divider()

                infoSection

                Spacer().frame(height: 20)
            }
            .padding()
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Keyboard Shortcuts Feature")
                .font(.headline)

            Text("When enabled, the indicator will show the most common keyboard shortcuts for the selected layout:")
                .font(.body)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Label("Special character combinations", systemImage: "keyboard")

                Label("Language-specific shortcuts", systemImage: "character.textbox")

                Label("Dead keys and diacritics", systemImage: "character.cursor.ibeam")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.leading)

            Text("Note: Shortcuts are automatically detected based on your keyboard layout configuration.")
                .font(.caption)
                .foregroundColor(.orange)
                .padding(.top, 8)
        }
    }
}
