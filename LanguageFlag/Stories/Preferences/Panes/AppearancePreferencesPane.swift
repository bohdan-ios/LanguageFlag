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

                Spacer().frame(height: 20)
            }
            .padding()
        }
    }
    
    private var opacitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Opacity")
                .font(.headline)

            HStack {
                Slider(value: $preferences.opacity, in: 0.5...1.0, step: 0.05)

                Text(String(format: "%.0f%%", preferences.opacity * 100))
                    .frame(width: 45, alignment: .trailing)
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
    
    private var animationSpeedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Animation Speed")
                .font(.headline)

            HStack {
                Slider(value: $preferences.animationDuration, in: 0.1...1.0, step: 0.1)

                Text(String(format: "%.1fs", preferences.animationDuration))
                    .frame(width: 40, alignment: .trailing)
            }

            Text("Duration of show/hide animations")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Private
private extension AppearancePreferencesPane {
    
    func animationStyleButton(for style: AnimationStyle) -> some View {
        Button(action: { preferences.animationStyle = style }) {
            Text(style.description)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(preferences.animationStyle == style ? Color.accentColor : Color.gray.opacity(0.15))
                .foregroundColor(preferences.animationStyle == style ? .white : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
