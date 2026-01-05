import SwiftUI

/// Individual position cell button in the position picker grid
struct PositionButton: View {

    // MARK: - Variables
    @Binding private var selectedPosition: DisplayPosition
    @Binding private var isDragging: Bool

    @State private var isHovered = false

    private let position: DisplayPosition
    private let width: CGFloat
    private let height: CGFloat

    private var isSelected: Bool {
        selectedPosition == position
    }
    
    // MARK: - Init
    init(
        position: DisplayPosition,
        selectedPosition: Binding<DisplayPosition>,
        isDragging: Binding<Bool>,
        width: CGFloat,
        height: CGFloat
    ) {
        self.position = position
        self._selectedPosition = selectedPosition
        self._isDragging = isDragging
        self.width = width
        self.height = height
    }

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        ZStack {
            cellBackground

            if isSelected {
                selectionIndicator
            }
        }
        .frame(width: width, height: height)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
            if isDragging && hovering {
                selectedPosition = position
            }
        }
    }
    
    private var cellBackground: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(isSelected ? Color.accentColor.opacity(0.25) : (isHovered && !isDragging ? Color.gray.opacity(0.2) : Color.clear))
    }
    
    private var selectionIndicator: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.accentColor)
            .frame(width: width * 0.4, height: height * 0.5)
            .shadow(color: Color.accentColor.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}
