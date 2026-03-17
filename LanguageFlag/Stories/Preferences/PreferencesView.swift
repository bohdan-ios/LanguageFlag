import SwiftUI

// MARK: - State holder (re-renders on objectWillChange, but its body is trivial)

/// Owns the UserPreferences @StateObject and projects bindings into the static PreferencesView.
/// Kept separate so that PreferencesView.body never re-runs due to UserPreferences changes.
struct PreferencesView: View {

    @StateObject private var preferences = UserPreferences.shared

    var body: some View {
        PreferencesContentView(
            displayPosition: $preferences.displayPosition,
            windowSize: $preferences.windowSize,
            showInMenuBar: $preferences.showInMenuBar,
            showCapsLockIndicator: $preferences.showCapsLockIndicator,
            bypassClick: $preferences.bypassClick,
            opacity: $preferences.opacity,
            animationStyle: $preferences.animationStyle,
            animationDuration: $preferences.animationDuration,
            displayDuration: $preferences.displayDuration,
            resetAnimationOnChange: $preferences.resetAnimationOnChange,
            showShortcuts: $preferences.showShortcuts,
            onReset: { UserPreferences.shared.resetToDefaults() }
        )
    }
}

// MARK: - Static content (TabView — body only re-runs when its own @State/@Binding values change)

/// Main preferences view - tab-based navigation across preference panes.
/// Takes all preferences as bindings so its body is not invalidated by unrelated property changes.
private struct PreferencesContentView: View {

    // MARK: - Bindings from UserPreferences
    @Binding var displayPosition: DisplayPosition
    @Binding var windowSize: WindowSize
    @Binding var showInMenuBar: Bool
    @Binding var showCapsLockIndicator: Bool
    @Binding var bypassClick: Bool
    @Binding var opacity: Double
    @Binding var animationStyle: AnimationStyle
    @Binding var animationDuration: Double
    @Binding var displayDuration: Double
    @Binding var resetAnimationOnChange: Bool
    @Binding var showShortcuts: Bool
    let onReset: () -> Void

    @State private var selectedPane: PreferencePane = .general

    // MARK: - Views
    var body: some View {
        TabView(selection: $selectedPane) {
            ForEach(PreferencePane.availableCases) { pane in
                paneContent(for: pane)
                    .tabItem {
                        Label(pane.rawValue, systemImage: pane.icon)
                    }
                    .tag(pane)
            }
        }
        .padding(.top, 8)
        .frame(width: 817, height: 505)
    }

    @ViewBuilder
    private func paneContent(for pane: PreferencePane) -> some View {
        switch pane {
        case .general:
            GeneralPreferencesPane(
                displayPosition: $displayPosition,
                windowSize: $windowSize,
                showInMenuBar: $showInMenuBar,
                showCapsLockIndicator: $showCapsLockIndicator,
                bypassClick: $bypassClick,
                onReset: onReset
            )

        case .appearance:
            AppearancePreferencesPane(
                opacity: $opacity,
                animationStyle: $animationStyle,
                animationDuration: $animationDuration,
                displayDuration: $displayDuration,
                resetAnimationOnChange: $resetAnimationOnChange
            )

        case .customImages:
            CustomImagesPreferencesPane()

        case .shortcuts:
            #if FEATURE_SHORTCUTS
            ShortcutsPreferencesPane(showShortcuts: $showShortcuts)
            #else
            EmptyView()
            #endif

        case .analytics:
            #if FEATURE_ANALYTICS
            AnalyticsPreferencesPane()
            #else
            EmptyView()
            #endif

        case .groups:
            #if FEATURE_GROUPS
            GroupsPreferencesPane()
            #else
            EmptyView()
            #endif

        case .about:
            AboutPreferencesPane()
        }
    }
}

// MARK: - Preview
struct PreferencesView_Previews: PreviewProvider {

    static var previews: some View {
        PreferencesView()
    }
}
