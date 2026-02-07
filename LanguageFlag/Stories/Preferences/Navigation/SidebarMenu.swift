import SwiftUI

/// Sidebar menu containing all preference pane options
struct SidebarMenu: View {

    // MARK: - Variables
    @Binding private var selectedPane: PreferencePane
    
    // MARK: - Init
    init(selectedPane: Binding<PreferencePane>) {
        self._selectedPane = selectedPane
    }
    
    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(PreferencePane.allCases) { pane in
                SidebarMenuItem(
                    title: pane.rawValue,
                    icon: pane.icon,
                    isSelected: selectedPane == pane
                ) {
                    selectedPane = pane
                }
            }

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(width: 160)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
}
