import SwiftUI

/// Appearance preferences pane for opacity, animation style, and speed
struct AppearancePreferencesPane: View {

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
                opacitySection

                Divider()

                animationStyleSection

                Divider()

                animationSpeedSection

                Divider()

                animationBehaviorSection

                Spacer()
                    .frame(height: 16)
            }
            .padding()
        }
    }
    
    private let opacitySteps: [Double] = stride(from: 0.5, through: 1.0, by: 0.1).map { $0 }

    private var opacitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Opacity")
                .font(.headline)

            HStack(alignment: .top, spacing: 8) {
                VStack(spacing: 2) {
                    Slider(value: $preferences.opacity, in: 0.5...1.0, step: 0.05)
                        .accessibilityIdentifier("opacity_slider")

                    SliderTickLabels(labels: opacitySteps.map { String(format: "%.0f%%", $0 * 100) })
                }

                Text(String(format: "%.0f%%", preferences.opacity * 100))
                    .frame(width: 95, alignment: .trailing)
                    .accessibilityIdentifier("opacity_value")
            }

            Text("Transparency of the indicator window")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var animationStyleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Animation Style")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
                ForEach(AnimationStyle.allCases, id: \.self) { style in
                    animationStyleButton(for: style)
                }
            }

            Text("How the indicator appears and disappears")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var animationBehaviorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Animation Behavior")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reset animation on layout change")
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("When enabled, the animation restarts each time the keyboard layout changes. When disabled, the current animation continues uninterrupted.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle("Reset animation on layout change", isOn: $preferences.resetAnimationOnChange)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .accessibilityLabel("Reset animation on layout change")
                    .accessibilityIdentifier("reset_animation_toggle")
            }
        }
    }

    private let animationSpeedSteps: [Double] = stride(from: 0.1, through: 1.0, by: 0.1).map { $0 }

    private var animationSpeedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Animation Speed")
                .font(.headline)

            HStack(alignment: .top, spacing: 8) {
                VStack(spacing: 2) {
                    Slider(value: $preferences.animationDuration, in: 0.1...1.0, step: 0.1)
                        .accessibilityIdentifier("animation_duration_slider")

                    SliderTickLabels(labels: animationSpeedSteps.map { String(format: "%.1f", $0) })
                }

                Text(String(format: "%.1fs", preferences.animationDuration))
                    .frame(width: 95, alignment: .trailing)
                    .accessibilityIdentifier("animation_duration_value")
            }

            Text("Duration of show/hide animations")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Private
private extension AppearancePreferencesPane {
    
    private func animationStyleButton(for style: AnimationStyle) -> some View {
        Button {
            preferences.animationStyle = style
        } label: {
            Text(style.description)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(preferences.animationStyle == style ? Color.accentColor : Color.gray.opacity(0.15))
                .foregroundColor(preferences.animationStyle == style ? .white : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("animation_style_\(style.rawValue.lowercased())") // ← Added for UI testing!
        .accessibilityLabel(style.description)
    }
}
