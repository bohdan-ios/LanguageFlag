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
    
    private var paneContent: some View {
        Group {
            switch selectedPane {
            case .general:
                GeneralPreferencesPane(preferences: preferences)

            case .appearance:
                AppearancePreferencesPane(preferences: preferences)

            case .shortcuts:
                ShortcutsPreferencesPane(preferences: preferences)

            case .analytics:
                AnalyticsPreferencesPane()

            case .groups:
                GroupsPreferencesPane()
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
