import SwiftUI

/// General preferences pane for display duration, position, size, and menu bar settings
struct GeneralPreferencesPane: View {

    // MARK: - Variables
    @ObservedObject private var preferences: UserPreferences
    @State private var showResetConfirmation = false
    
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

                capsLockToggle

                Spacer()
                    .frame(height: 20)

                resetButton
            }
            .padding()
        }
    }
    
    private let displayDurationSteps: [Double] = stride(from: 0.5, through: 5.0, by: 0.5).map { $0 }

    private var displayDurationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Display Duration")
                .font(.headline)

            HStack(alignment: .top, spacing: 8) {
                VStack(spacing: 2) {
                    Slider(value: $preferences.displayDuration, in: 0.5...5.0, step: 0.5)

                    SliderTickLabels(labels: displayDurationSteps.map { String(format: "%.1f", $0) })
                }

                Text(String(format: "%.1fs", preferences.displayDuration))
                    .frame(width: 95, alignment: .trailing)
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

            HStack(alignment: .top, spacing: 8) {
                VStack(spacing: 2) {
                    Slider(
                        value: Binding(
                            get: { Double(WindowSize.allCases.firstIndex(of: preferences.windowSize) ?? 1) },
                            set: { preferences.windowSize = WindowSize.allCases[Int($0)] }
                        ),
                        in: 0...3,
                        step: 1
                    )

                    SliderTickLabels(labels: WindowSize.allCases.map(\.description))
                }

                Text(preferences.windowSize.description)
                    .frame(width: 95, alignment: .trailing)
                    .foregroundColor(.primary)
            }

            Text("Size of the language indicator window")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var menuBarToggle: some View {
        HStack {
            Text("Show current layout in menu bar")

            Spacer()

            Toggle("Show current layout in menu bar", isOn: $preferences.showInMenuBar)
                .toggleStyle(.switch)
                .labelsHidden()
                .accessibilityLabel("Show current layout in menu bar")
                .accessibilityIdentifier("menuBarToggle")
                .help("Display the current keyboard layout in the menu bar")
        }
    }

    private var capsLockToggle: some View {
        HStack {
            Text("Show indicator on Caps Lock change")

            Spacer()

            Toggle("Show indicator on Caps Lock change", isOn: $preferences.showCapsLockIndicator)
                .toggleStyle(.switch)
                .labelsHidden()
                .accessibilityLabel("Show indicator on Caps Lock change")
                .accessibilityIdentifier("capsLockToggle")
                .help("Show the language indicator window when Caps Lock is toggled")
        }
    }
    
    private var resetButton: some View {
        HStack {
            #if FEATURE_RECALCULATE_FRAMES
            Button("Recalculate Window Frames") {
                NotificationCenter.default.post(name: .recalculateWindowFrames, object: nil)
            }
            .buttonStyle(.bordered)
            .help("Force recalculate all indicator windows for connected displays")
            #endif

            Spacer()

            Button("Reset to Defaults") {
                showResetConfirmation = true
            }
            .buttonStyle(.bordered)
            .confirmationDialog(
                "Reset all settings to their defaults?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    preferences.resetToDefaults()
                }
            }
        }
    }
}
