//
//  PreferencesView.swift
//  LanguageFlag
//
//  Created by Claude on 01/01/2026.
//

import SwiftUI

struct PreferencesView: View {

    @ObservedObject var preferences = UserPreferences.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralPreferencesView(preferences: preferences)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
                .tag(0)

            AppearancePreferencesView(preferences: preferences)
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
                .tag(1)

            ShortcutsPreferencesView(preferences: preferences)
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
                .tag(2)
        }
        .padding(.top, 8)
        .frame(width: 500, height: 500)
    }
}

// MARK: - General Preferences
struct GeneralPreferencesView: View {

    @ObservedObject var preferences: UserPreferences

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    // Display Duration
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

                    Divider()

                    // Display Position
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Position")
                            .font(.headline)
                        Picker("", selection: $preferences.displayPosition) {
                            ForEach(DisplayPosition.allCases, id: \.self) { position in
                                Text(position.description).tag(position)
                            }
                        }
                        .pickerStyle(.menu)
                        Text("Where the indicator appears on screen")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Window Size
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Window Size")
                            .font(.headline)
                        Picker("", selection: $preferences.windowSize) {
                            ForEach(WindowSize.allCases, id: \.self) { size in
                                Text(size.description).tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                        Text("Size of the language indicator")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Menu Bar
                    Toggle("Show current layout in menu bar", isOn: $preferences.showInMenuBar)
                        .help("Display the current keyboard layout in the menu bar")
                }
                .padding()
            }

            Spacer()

            // Reset Button
            HStack {
                Spacer()
                Button("Reset to Defaults") {
                    preferences.resetToDefaults()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}

// MARK: - Appearance Preferences
struct AppearancePreferencesView: View {

    @ObservedObject var preferences: UserPreferences

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    // Opacity
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

                    Divider()

                    // Animation Style
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Animation Style")
                            .font(.headline)
                        Picker("", selection: $preferences.animationStyle) {
                            ForEach(AnimationStyle.allCases, id: \.self) { style in
                                Text(style.description).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        Text("How the indicator appears and disappears")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Animation Duration
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

                    Divider()

                    // Preview
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Preview")
//                            .font(.headline)
//                        HStack {
//                            Spacer()
//                            RoundedRectangle(cornerRadius: 16)
//                                .fill(Color.gray.opacity(preferences.opacity))
//                                .frame(width: 150, height: 93)
//                                .overlay(
//                                    VStack {
//                                        Image(systemName: "flag.fill")
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(height: 40)
//                                        Text("Preview")
//                                            .font(.caption)
//                                    }
//                                    .foregroundColor(.white)
//                                )
//                            Spacer()
//                        }
//                        .padding(.vertical)
//                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

// MARK: - Shortcuts Preferences
struct ShortcutsPreferencesView: View {

    @ObservedObject var preferences: UserPreferences

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    // Show Shortcuts
                    Toggle("Show keyboard shortcuts for current layout", isOn: $preferences.showShortcuts)
                        .help("Display common keyboard shortcuts when switching layouts")

                    Divider()

                    // Info
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

                    Spacer()
                }
                .padding()
            }
        }
    }
}

// MARK: - Preview
struct PreferencesView_Previews: PreviewProvider {

    static var previews: some View {
        PreferencesView()
    }
}
