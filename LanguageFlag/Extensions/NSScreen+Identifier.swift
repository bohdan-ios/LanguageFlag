import Cocoa

extension NSScreen {

    /// Returns a unique, stable identifier for the screen using CGDirectDisplayID
    var identifier: String {
        let screenNumber = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0

        return "\(screenNumber)"
    }
}
