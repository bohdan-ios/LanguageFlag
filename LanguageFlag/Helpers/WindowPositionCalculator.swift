import Foundation

/// Pure calculation logic for window positioning
/// Handles frame calculation, slide direction, and distance computation
struct WindowPositionCalculator {

    // MARK: - Frame Calculation
    
    /// Calculates the window frame for a given screen, position, and size
    /// - Parameters:
    ///   - screenRect: The visible frame of the target screen
    ///   - position: The desired display position
    ///   - size: The window size configuration
    /// - Returns: The calculated window frame
    func calculateWindowFrame(
        in screenRect: CGRect,
        position: DisplayPosition,
        size: WindowSize
    ) -> CGRect {
        let dimensions = size.dimensions
        let origin = calculateOrigin(for: position, in: screenRect, size: dimensions)
        
        return CGRect(
            x: origin.x,
            y: origin.y,
            width: dimensions.width,
            height: dimensions.height
        )
    }
    
    // MARK: - Slide Direction
    
    /// Determines the optimal slide direction based on window position relative to screen edges
    /// Windows slide towards the nearest edge to avoid appearing on adjacent monitors
    /// - Parameters:
    ///   - windowFrame: The current window frame
    ///   - screenRect: The visible frame of the screen
    /// - Returns: The optimal slide direction
    func slideDirection(
        for windowFrame: CGRect,
        in screenRect: CGRect
    ) -> SlideDirection {
        // Calculate distances to each edge
        let distanceToTop = screenRect.maxY - windowFrame.maxY
        let distanceToBottom = windowFrame.minY - screenRect.minY
        let distanceToLeft = windowFrame.minX - screenRect.minX
        let distanceToRight = screenRect.maxX - windowFrame.maxX
        
        // Find the minimum distance
        let minDistance = min(distanceToTop, distanceToBottom, distanceToLeft, distanceToRight)
        
        // Slide towards the nearest edge
        if minDistance == distanceToTop {
            return .up
        } else if minDistance == distanceToBottom {
            return .down
        } else if minDistance == distanceToLeft {
            return .left
        } else {
            return .right
        }
    }
    
    // MARK: - Slide Distance
    
    /// Calculates the maximum slide distance to prevent window from appearing on adjacent monitors
    /// Uses min(distance to edge, window dimension) to stay within screen bounds
    /// - Parameters:
    ///   - direction: The slide direction
    ///   - windowFrame: The current window frame
    ///   - screenRect: The visible frame of the screen
    /// - Returns: The maximum safe slide distance
    func maxSlideDistance(
        for direction: SlideDirection,
        windowFrame: CGRect,
        screenRect: CGRect
    ) -> CGFloat {
        switch direction {
        case .up:
            let distanceToEdge = screenRect.maxY - windowFrame.maxY
            let baseDistance = min(distanceToEdge, windowFrame.height)
            let extraDistance = max(0, distanceToEdge - windowFrame.height)
            return baseDistance + min(extraDistance, 50)
            
        case .down:
            let distanceToEdge = windowFrame.minY - screenRect.minY
            let baseDistance = min(distanceToEdge, windowFrame.height)
            let extraDistance = max(0, distanceToEdge - windowFrame.height)
            return baseDistance + min(extraDistance, 50)
            
        case .left:
            let distanceToEdge = windowFrame.minX - screenRect.minX
            let baseDistance = min(distanceToEdge, windowFrame.width)
            let extraDistance = max(0, distanceToEdge - windowFrame.width)
            return baseDistance + min(extraDistance, 50)
            
        case .right:
            let distanceToEdge = screenRect.maxX - windowFrame.maxX
            let baseDistance = min(distanceToEdge, windowFrame.width)
            let extraDistance = max(0, distanceToEdge - windowFrame.width)
            return baseDistance + min(extraDistance, 50)
        }
    }
}

// MARK: - Private
private extension WindowPositionCalculator {
    
    /// Calculates the origin point for a window based on position and screen
    func calculateOrigin(
        for position: DisplayPosition,
        in screen: CGRect,
        size: (width: CGFloat, height: CGFloat)
    ) -> (x: CGFloat, y: CGFloat) {
        // Use percentage-based padding for better multi-monitor support
        let horizontalPadding = min(50, screen.width * 0.05)
        let verticalPadding = min(50, screen.height * 0.05)
        
        let x: CGFloat
        let y: CGFloat
        
        // Calculate X position
        switch position {
        case .topLeft, .centerLeft, .bottomLeft:
            x = screen.minX + horizontalPadding
        case .topCenter, .center, .bottomCenter:
            x = screen.minX + (screen.width - size.width) / 2
        case .topRight, .centerRight, .bottomRight:
            x = screen.maxX - size.width - horizontalPadding
        }
        
        // Calculate Y position
        switch position {
        case .topLeft, .topCenter, .topRight:
            y = screen.maxY - size.height - verticalPadding
        case .centerLeft, .center, .centerRight:
            y = screen.minY + (screen.height - size.height) / 2
        case .bottomLeft, .bottomCenter, .bottomRight:
            y = screen.minY + verticalPadding
        }
        
        return (x, y)
    }
}
