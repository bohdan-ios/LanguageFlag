import Foundation
import AppKit
@testable import LanguageFlag

// MARK: - Mock UserDefaults

/// Mock UserDefaults for isolated testing
final class MockUserDefaults: UserDefaults {
    private var storage: [String: Any] = [:]
    
    override func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    override func object(forKey defaultName: String) -> Any? {
        return storage[defaultName]
    }
    
    override func data(forKey defaultName: String) -> Data? {
        return storage[defaultName] as? Data
    }
    
    override func bool(forKey defaultName: String) -> Bool {
        return storage[defaultName] as? Bool ?? false
    }
    
    override func string(forKey defaultName: String) -> String? {
        return storage[defaultName] as? String
    }
    
    override func integer(forKey defaultName: String) -> Int {
        return storage[defaultName] as? Int ?? 0
    }
    
    override func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }
    
    func clearAll() {
        storage.removeAll()
    }
}

// MARK: - Mock Layout Mapping Provider

/// Mock layout mapping provider for testing
final class MockLayoutMappingProvider: LayoutMappingProvider {
    var mappings: [String: String] = [:]
    var shouldThrowError = false
    var errorToThrow: Error = LayoutImageError.layoutNotFound("test")
    
    func imageName(for layout: String) throws -> String {
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let imageName = mappings[layout] else {
            throw LayoutImageError.layoutNotFound(layout)
        }
        
        return imageName
    }
    
    /// Convenience method to add test mappings
    func addMapping(layout: String, imageName: String) {
        mappings[layout] = imageName
    }
}

// MARK: - Mock Image Cache

/// Mock image cache for testing
final class MockImageCache: ImageCaching {
    private(set) var storage: [String: NSImage] = [:]
    private(set) var cacheCallCount = 0
    private(set) var retrieveCallCount = 0
    
    func cache(_ image: NSImage, for key: String) {
        storage[key] = image
        cacheCallCount += 1
    }
    
    func cachedImage(for key: String) -> NSImage? {
        retrieveCallCount += 1
        return storage[key]
    }
    
    func clear() {
        storage.removeAll()
        cacheCallCount = 0
        retrieveCallCount = 0
    }
}

// MARK: - Mock Image Renderer

/// Mock image renderer for fast, predictable testing
final class MockImageRenderer: ImageRendering {
    var renderCallCount = 0
    var asyncRenderCallCount = 0
    var shouldIncludeCapsLock = false
    
    // Capture parameters from last call for verification
    private(set) var lastRenderedSize: NSSize?
    private(set) var lastCapsLockState: Bool?
    
    func renderImage(_ baseImage: NSImage, size: NSSize, withCapsLock: Bool) -> NSImage {
        renderCallCount += 1
        lastRenderedSize = size
        lastCapsLockState = withCapsLock
        
        // Return a simple test image
        return createTestImage(size: size, withCapsLock: withCapsLock)
    }
    
    func renderImageAsync(_ baseImage: NSImage, size: NSSize, withCapsLock: Bool) async -> NSImage {
        asyncRenderCallCount += 1
        lastRenderedSize = size
        lastCapsLockState = withCapsLock
        
        // Simulate some async work
        try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
        
        return createTestImage(size: size, withCapsLock: withCapsLock)
    }
    
    private func createTestImage(size: NSSize, withCapsLock: Bool) -> NSImage {
        NSImage(size: size, flipped: false) { rect in
            // Draw different color based on caps lock state for testing
            if withCapsLock {
                NSColor.red.setFill()
            } else {
                NSColor.blue.setFill()
            }
            rect.fill()
            return true
        }
    }
    
    func reset() {
        renderCallCount = 0
        asyncRenderCallCount = 0
        lastRenderedSize = nil
        lastCapsLockState = nil
    }
}

// MARK: - Mock Notification Center

/// Mock notification center for testing notification behavior
final class MockNotificationCenter {
    private(set) var postedNotifications: [(name: Notification.Name, object: Any?)] = []
    
    func post(name: Notification.Name, object: Any?) {
        postedNotifications.append((name, object))
    }
    
    func didPost(name: Notification.Name) -> Bool {
        postedNotifications.contains { $0.name == name }
    }
    
    func postCount(for name: Notification.Name) -> Int {
        postedNotifications.filter { $0.name == name }.count
    }
    
    func clear() {
        postedNotifications.removeAll()
    }
}

// MARK: - Test Data Builders

/// Builder for creating test layout usage records
struct TestLayoutRecordBuilder {
    var layoutName = "US"
    var appName = "Xcode"
    var startTime = Date(timeIntervalSince1970: 1000)
    var endTime = Date(timeIntervalSince1970: 1300)
    
    func build() -> LayoutUsageRecord {
        LayoutUsageRecord(
            layoutName: layoutName,
            appName: appName,
            startTime: startTime,
            endTime: endTime
        )
    }
    
    func withLayout(_ name: String) -> TestLayoutRecordBuilder {
        var builder = self
        builder.layoutName = name
        return builder
    }
    
    func withApp(_ name: String) -> TestLayoutRecordBuilder {
        var builder = self
        builder.appName = name
        return builder
    }
    
    func withDuration(_ seconds: TimeInterval) -> TestLayoutRecordBuilder {
        var builder = self
        builder.endTime = builder.startTime.addingTimeInterval(seconds)
        return builder
    }
}

/// Builder for creating test layout statistics
struct TestLayoutStatisticsBuilder {
    var layoutName = "US"
    var totalDuration: TimeInterval = 300
    var switchCount = 1
    var lastUsed: Date? = Date()
    var percentage: Double = 0.0
    
    func build() -> LayoutStatistics {
        var stats = LayoutStatistics(
            layoutName: layoutName,
            totalDuration: totalDuration,
            switchCount: switchCount,
            lastUsed: lastUsed
        )
        stats.percentage = percentage
        return stats
    }
    
    func withLayout(_ name: String) -> TestLayoutStatisticsBuilder {
        var builder = self
        builder.layoutName = name
        return builder
    }
    
    func withDuration(_ seconds: TimeInterval) -> TestLayoutStatisticsBuilder {
        var builder = self
        builder.totalDuration = seconds
        return builder
    }
}

// MARK: - Test Helpers

extension NSImage {
    /// Create a simple test image with a specific color
    static func testImage(size: NSSize, color: NSColor) -> NSImage {
        NSImage(size: size, flipped: false) { rect in
            color.setFill()
            rect.fill()
            return true
        }
    }
}

// MARK: - Test Constants

enum TestConstants {
    static let defaultIconSize = NSSize(width: 24, height: 24)
    static let testLayouts = ["US", "French", "German", "Spanish", "Japanese"]
    static let testApps = ["Xcode", "Safari", "Mail", "Terminal", "Notes"]
}
