import SwiftUI

/// Represents each preference pane in the sidebar
enum PreferencePane: String, CaseIterable, Identifiable {

    case general = "General"
    case appearance = "Appearance"
    case shortcuts = "Shortcuts"
    case analytics = "Analytics"
    case groups = "Groups"
    
    // MARK: - Properties
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .appearance: return "paintbrush"
        case .shortcuts: return "keyboard"
        case .analytics: return "chart.bar"
        case .groups: return "folder"
        }
    }
}
