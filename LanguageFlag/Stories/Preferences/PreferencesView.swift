import SwiftUI

/// Main preferences view - orchestrates sidebar navigation and content panes
struct PreferencesView: View {

    // MARK: - Variables
    @ObservedObject private var preferences = UserPreferences.shared

    @State private var selectedPane: PreferencePane = .general

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        HStack(spacing: 0) {
            SidebarMenu(selectedPane: $selectedPane)

            Divider()

            paneContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 809, height: 500)
    }
    
    @ViewBuilder
    private var paneContent: some View {
        switch selectedPane {
        case .general:
            GeneralPreferencesPane(preferences: preferences)

        case .appearance:
            AppearancePreferencesPane(preferences: preferences)

        case .shortcuts:
            #if FEATURE_SHORTCUTS
            ShortcutsPreferencesPane(preferences: preferences)
            #else
            GeneralPreferencesPane(preferences: preferences)
            #endif

        case .analytics:
            #if FEATURE_ANALYTICS
            AnalyticsPreferencesPane()
            #else
            GeneralPreferencesPane(preferences: preferences)
            #endif

        case .groups:
            #if FEATURE_GROUPS
            GroupsPreferencesPane()
            #else
            GeneralPreferencesPane(preferences: preferences)
            #endif
        }
    }
}

// MARK: - Preview
struct PreferencesView_Previews: PreviewProvider {

    static var previews: some View {
        PreferencesView()
    }
}
