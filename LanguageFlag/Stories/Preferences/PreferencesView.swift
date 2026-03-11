import SwiftUI

/// Main preferences view - tab-based navigation across preference panes
struct PreferencesView: View {

    // MARK: - Variables
    @StateObject private var preferences = UserPreferences.shared

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
            GeneralPreferencesPane(preferences: preferences)

        case .appearance:
            AppearancePreferencesPane(preferences: preferences)

        case .shortcuts:
            #if FEATURE_SHORTCUTS
            ShortcutsPreferencesPane(preferences: preferences)
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
