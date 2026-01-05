import SwiftUI

/// Individual menu item in the preferences sidebar
struct SidebarMenuItem: View {
    
    // MARK: - Variables
    @State private var isHovered = false

    private let title: String
    private let icon: String
    private let isSelected: Bool
    private let action: () -> Void
    
    // MARK: - Init
    init(
        title: String,
        icon: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .frame(width: 20)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(backgroundView)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(isSelected ? Color.accentColor : (isHovered ? Color.gray.opacity(0.2) : Color.clear))
    }
}
