import SwiftUI

/// General preferences pane for display duration, position, size, and menu bar settings
struct GeneralPreferencesPane: View {

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
                displayDurationSection

                Divider()

                displayPositionSection

                Divider()

                windowSizeSection

                Divider()

                menuBarToggle

                Spacer().frame(height: 20)

                resetButton
            }
            .padding()
        }
    }
    
    private var displayDurationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Display Duration")
                .font(.headline)

            HStack {
                Slider(value: $preferences.displayDuration, in: 0.5...5.0, step: 0.5)

                Text(String(format: "%.1fs", preferences.displayDuration))
                    .frame(width: 40, alignment: .trailing)
            }

            Text("How long the language indicator stays visible")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var displayPositionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Display Position")
                .font(.headline)

            PositionPickerView(selectedPosition: $preferences.displayPosition)
                .frame(height: 160)

            Text("Click a position to place the indicator on your screen")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var windowSizeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Window Size")
                .font(.headline)

            HStack(spacing: 12) {
                Text("Small")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Slider(
                    value: Binding(
                        get: { Double(WindowSize.allCases.firstIndex(of: preferences.windowSize) ?? 1) },
                        set: { preferences.windowSize = WindowSize.allCases[Int($0)] }
                    ),
                    in: 0...3,
                    step: 1
                )

                Text("Large")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(preferences.windowSize.description)
                    .frame(width: 60, alignment: .trailing)
                    .foregroundColor(.primary)
            }

            Text("Size of the language indicator window")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var menuBarToggle: some View {
        Toggle("Show current layout in menu bar", isOn: $preferences.showInMenuBar)
            .help("Display the current keyboard layout in the menu bar")
    }
    
    private var resetButton: some View {
        HStack {
            Spacer()

            Button("Reset to Defaults") {
                preferences.resetToDefaults()
            }
            .buttonStyle(.bordered)
        }
    }
}
