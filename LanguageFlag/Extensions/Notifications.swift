import Foundation

extension Notification.Name {
    
    // MARK: - Preferences
    
    /// Posted when a preference change requires a preview animation
    static let preferencesPreviewRequested = Notification.Name("preferencesPreviewRequested")
    
    /// Posted when window frames need to be recalculated due to screen or preference changes
    static let recalculateWindowFrames = Notification.Name("recalculateWindowFrames")
    
    // MARK: - Layout Groups
    
    /// Posted when the active layout group changes
    /// Object contains the new LayoutGroup, or nil if deactivated
    static let layoutGroupChanged = Notification.Name("layoutGroupChanged")
}
