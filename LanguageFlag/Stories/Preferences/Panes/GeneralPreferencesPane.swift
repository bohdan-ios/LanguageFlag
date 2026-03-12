import SwiftUI
import LaunchAtLogin

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

                indicatorBehaviorSection

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
    
    private var indicatorBehaviorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Indicator Behavior")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                // Menu Bar Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Show current layout in menu bar")
                        Text("Display the current keyboard layout in the macOS menu bar.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("Show current layout in menu bar", isOn: $preferences.showInMenuBar)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .accessibilityIdentifier("menuBarToggle")
                }

                // Caps Lock Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Show indicator on Caps Lock change")
                        Text("Show the language window when Caps Lock is toggled.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("Show indicator on Caps Lock change", isOn: $preferences.showCapsLockIndicator)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .accessibilityIdentifier("capsLockToggle")
                }

                // Bypass Click Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bypass click")
                        Text("When enabled, clicks on the language window pass through to the window underneath.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("Bypass click", isOn: $preferences.bypassClick)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .accessibilityIdentifier("bypassClickToggle")
                }

                // Launch at Login Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Launch at login")

                        Text("Automatically open the app when you log in to your Mac.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    LaunchAtLogin.Toggle()
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .accessibilityIdentifier("launchAtLoginToggle")
                }
            }
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
