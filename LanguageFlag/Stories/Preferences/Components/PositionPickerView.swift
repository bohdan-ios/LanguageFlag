import SwiftUI

/// Visual grid picker for selecting display position
struct PositionPickerView: View {

    // MARK: - Variables
    @Binding private var selectedPosition: DisplayPosition

    @State private var isDragging = false

    private let screenWidth: CGFloat = 160
    private let screenHeight: CGFloat = 100
    private let cellSpacing: CGFloat = 3
    private let positions: [[DisplayPosition]] = [
        [.topLeft, .topCenter, .topRight],
        [.centerLeft, .center, .centerRight],
        [.bottomLeft, .bottomCenter, .bottomRight]
    ]

    private var cellWidth: CGFloat {
        (screenWidth - cellSpacing * 4) / 3
    }

    private var cellHeight: CGFloat {
        (screenHeight - cellSpacing * 4) / 3
    }
    
    // MARK: - Init
    init(selectedPosition: Binding<DisplayPosition>) {
        self._selectedPosition = selectedPosition
    }

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        HStack(spacing: 0) {
            Spacer()

            pickerGrid

            Spacer()
        }
        .frame(height: screenHeight)
    }
    
    private var pickerGrid: some View {
        GeometryReader { geometry in
            ZStack {
                screenBackground

                positionButtonsGrid
                    .padding(cellSpacing * 2)
                    .gesture(dragGesture(in: geometry.size))
            }
            .contentShape(Rectangle())
        }
        .frame(width: screenWidth, height: screenHeight)
    }
    
    private var screenBackground: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.15),
                        Color.gray.opacity(0.08)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 2)
            )
    }
    
    private var positionButtonsGrid: some View {
        VStack(spacing: cellSpacing) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: cellSpacing) {
                    ForEach(0..<3, id: \.self) { col in
                        PositionButton(
                            position: positions[row][col],
                            selectedPosition: $selectedPosition,
                            isDragging: $isDragging,
                            width: cellWidth,
                            height: cellHeight
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Private
private extension PositionPickerView {
    
    func dragGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                isDragging = true
                selectedPosition = positionForLocation(value.location)
            }
            .onEnded { _ in
                isDragging = false
            }
    }
    
    func positionForLocation(_ location: CGPoint) -> DisplayPosition {
        let padding = cellSpacing * 2
        let adjustedX = location.x - padding
        let adjustedY = location.y - padding

        var col = 0
        var row = 0

        var currentX: CGFloat = 0
        for c in 0..<3 {
            let cellEnd = currentX + cellWidth
            if adjustedX < cellEnd {
                col = c
                break
            }
            currentX = cellEnd + cellSpacing
            col = c + 1
        }

        var currentY: CGFloat = 0
        for r in 0..<3 {
            let cellEnd = currentY + cellHeight
            if adjustedY < cellEnd {
                row = r
                break
            }
            currentY = cellEnd + cellSpacing
            row = r + 1
        }

        col = min(2, max(0, col))
        row = min(2, max(0, row))

        return positions[row][col]
    }
}
