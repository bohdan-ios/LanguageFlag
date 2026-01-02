import Cocoa

extension NSScreen {

    /// Returns a unique identifier for the screen based on its frame
    var identifier: String {
        "\(frame.origin.x)-\(frame.origin.y)-\(frame.width)-\(frame.height)"
    }
}
