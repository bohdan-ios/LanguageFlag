import Testing
import Foundation
@testable import LanguageFlag

/// Test suite for Layout Analytics functionality
@Suite("Layout Analytics Tests")
struct LayoutAnalyticsTests {
    
    // MARK: - Test Lifecycle
    
    init() {
        // Clear any existing data before each test
        // Note: We'll need to use a mock UserDefaults for proper isolation
    }
    
    // MARK: - Statistics Calculation Tests
    
    @Suite("Duration Calculation")
    struct DurationCalculationTests {
        
        @Test("Calculate duration for single session")
        func testSingleSessionDuration() async throws {
            let startTime = Date(timeIntervalSince1970: 1000)
            let endTime = Date(timeIntervalSince1970: 1300)
            
            let record = LayoutUsageRecord(
                layoutName: "US",
                appName: "Xcode",
                startTime: startTime,
                endTime: endTime
            )
            
            #expect(record.duration == 300.0, "Duration should be 300 seconds")
        }
        
        @Test("Format duration in hours and minutes")
        func testFormattedDurationHours() async throws {
            let stats = LayoutStatistics(
                layoutName: "US",
                totalDuration: 7320, // 2h 2m
                switchCount: 1,
                lastUsed: Date()
            )
            
            #expect(stats.formattedDuration == "2h 2m", "Duration should format as hours and minutes")
        }
        
        @Test("Format duration in minutes only")
        func testFormattedDurationMinutes() async throws {
            let stats = LayoutStatistics(
                layoutName: "US",
                totalDuration: 185, // 3m 5s
                switchCount: 1,
                lastUsed: Date()
            )
            
            #expect(stats.formattedDuration == "3m 5s", "Duration should format as minutes and seconds")
        }
        
        @Test("Format duration in seconds only")
        func testFormattedDurationSeconds() async throws {
            let stats = LayoutStatistics(
                layoutName: "US",
                totalDuration: 45,
                switchCount: 1,
                lastUsed: Date()
            )
            
            #expect(stats.formattedDuration == "45s", "Duration should format as seconds only")
        }
    }
    
    @Suite("Percentage Calculation")
    struct PercentageCalculationTests {
        
        @Test("Calculate percentage with multiple layouts")
        func testPercentageCalculation() async throws {
            var stats1 = LayoutStatistics(
                layoutName: "US",
                totalDuration: 300,
                switchCount: 1,
                lastUsed: Date()
            )
            
            var stats2 = LayoutStatistics(
                layoutName: "French",
                totalDuration: 700,
                switchCount: 1,
                lastUsed: Date()
            )
            
            let totalDuration = stats1.totalDuration + stats2.totalDuration
            stats1.percentage = (stats1.totalDuration / totalDuration) * 100
            stats2.percentage = (stats2.totalDuration / totalDuration) * 100
            
            #expect(stats1.percentage == 30.0, "US layout should be 30%")
            #expect(stats2.percentage == 70.0, "French layout should be 70%")
        }
        
        @Test("Handle zero total duration")
        func testZeroTotalDuration() async throws {
            var stats = LayoutStatistics(
                layoutName: "US",
                totalDuration: 0,
                switchCount: 0,
                lastUsed: nil
            )
            
            let totalDuration: TimeInterval = 0
            stats.percentage = totalDuration > 0 ? (stats.totalDuration / totalDuration) * 100 : 0
            
            #expect(stats.percentage == 0.0, "Percentage should be 0 when total duration is 0")
        }
    }
    
    // MARK: - App Statistics Tests
    
    @Suite("App-Level Statistics")
    struct AppStatisticsTests {
        
        @Test("Identify most used layout for app")
        func testMostUsedLayout() async throws {
            let appStats = AppLayoutStatistics(
                appName: "Xcode",
                layoutUsage: [
                    "US": 300,
                    "French": 700,
                    "German": 200
                ],
                totalDuration: 1200,
                switchCount: 3
            )
            
            #expect(appStats.mostUsedLayout == "French", "French should be the most used layout")
        }
        
        @Test("Format app duration correctly")
        func testAppDurationFormatting() async throws {
            let appStats = AppLayoutStatistics(
                appName: "Xcode",
                layoutUsage: ["US": 7320],
                totalDuration: 7320, // 2h 2m
                switchCount: 1
            )
            
            #expect(appStats.formattedDuration == "2h 2m", "Duration should format as hours and minutes")
        }
        
        @Test("Format short app duration")
        func testShortAppDuration() async throws {
            let appStats = AppLayoutStatistics(
                appName: "Safari",
                layoutUsage: ["US": 30],
                totalDuration: 30, // Less than 1 minute
                switchCount: 1
            )
            
            #expect(appStats.formattedDuration == "< 1m", "Short duration should show as '< 1m'")
        }
        
        @Test("Handle app with no layouts")
        func testAppWithNoLayouts() async throws {
            let appStats = AppLayoutStatistics(
                appName: "Unknown",
                layoutUsage: [:],
                totalDuration: 0,
                switchCount: 0
            )
            
            #expect(appStats.mostUsedLayout == nil, "App with no layouts should have nil most used layout")
        }
    }
    
    // MARK: - Integration Tests (would require mock UserDefaults)
    
    @Suite("Session Tracking")
    struct SessionTrackingTests {
        
        @Test("Start tracking creates new session")
        func testStartTracking() async throws {
            let mockDefaults = MockUserDefaults()
            let analytics = LayoutAnalytics(defaults: mockDefaults)
            
            analytics.startTracking(layout: "US", app: "Xcode")
            
            // Verify analytics is enabled by default
            #expect(analytics.isEnabled == true, "Analytics should be enabled by default")
            
            // Note: We can't directly test private properties, but we can test the public API
            // When we stop tracking, it should save a record
            analytics.stopTracking()
            
            let records = try loadRecordsFromDefaults(mockDefaults)
            #expect(records.count == 1, "Should have saved one record")
            #expect(records.first?.layoutName == "US", "Layout name should be US")
            #expect(records.first?.appName == "Xcode", "App name should be Xcode")
        }
        
        @Test("Stop tracking saves record with correct duration")
        func testStopTracking() async throws {
            let mockDefaults = MockUserDefaults()
            let analytics = LayoutAnalytics(defaults: mockDefaults)
            
            // Start tracking
            analytics.startTracking(layout: "French", app: "Safari")
            
            // Wait a tiny bit to ensure time difference
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
            
            // Stop tracking
            analytics.stopTracking()
            
            // Verify record was saved
            let records = try loadRecordsFromDefaults(mockDefaults)
            #expect(records.count == 1, "Should have saved one record")
            
            let record = try #require(records.first)
            #expect(record.layoutName == "French", "Layout should be French")
            #expect(record.appName == "Safari", "App should be Safari")
            #expect(record.duration > 0, "Duration should be greater than 0")
            #expect(record.duration < 1.0, "Duration should be less than 1 second for this test")
        }
        
        @Test("Switching layouts ends previous session")
        func testSwitchingLayouts() async throws {
            let mockDefaults = MockUserDefaults()
            let analytics = LayoutAnalytics(defaults: mockDefaults)
            
            // Start tracking first layout
            analytics.startTracking(layout: "US", app: "Xcode")
            
            // Wait a bit
            try await Task.sleep(nanoseconds: 5_000_000) // 5ms
            
            // Switch to second layout (should end first session)
            analytics.startTracking(layout: "German", app: "Xcode")
            
            // Wait and switch again
            try await Task.sleep(nanoseconds: 5_000_000) // 5ms
            analytics.startTracking(layout: "French", app: "Terminal")
            
            // Stop final session
            analytics.stopTracking()
            
            // Verify three records were saved
            let records = try loadRecordsFromDefaults(mockDefaults)
            #expect(records.count == 3, "Should have saved three records")
            
            #expect(records[0].layoutName == "US", "First record should be US")
            #expect(records[1].layoutName == "German", "Second record should be German")
            #expect(records[2].layoutName == "French", "Third record should be French")
        }
        
        @Test("Analytics disabled prevents tracking")
        func testAnalyticsDisabled() async throws {
            let mockDefaults = MockUserDefaults()
            let analytics = LayoutAnalytics(defaults: mockDefaults)
            
            // Disable analytics
            analytics.isEnabled = false
            
            // Try to track
            analytics.startTracking(layout: "US", app: "Xcode")
            analytics.stopTracking()
            
            // Verify no records were saved
            let records = try loadRecordsFromDefaults(mockDefaults)
            #expect(records.count == 0, "Should not save records when analytics is disabled")
        }
        
        @Test("Get statistics aggregates data correctly")
        func testGetStatistics() async throws {
            let mockDefaults = MockUserDefaults()
            let analytics = LayoutAnalytics(defaults: mockDefaults)
            
            // Create some tracking sessions
            analytics.startTracking(layout: "US", app: "Xcode")
            try await Task.sleep(nanoseconds: 10_000_000)
            analytics.startTracking(layout: "French", app: "Safari")
            try await Task.sleep(nanoseconds: 20_000_000)
            analytics.startTracking(layout: "US", app: "Terminal")
            try await Task.sleep(nanoseconds: 10_000_000)
            analytics.stopTracking()
            
            // Get statistics
            let statistics = analytics.getStatistics()
            
            #expect(statistics.count == 2, "Should have statistics for 2 layouts")
            
            // Find US and French statistics
            let usStats = statistics.first { $0.layoutName == "US" }
            let frenchStats = statistics.first { $0.layoutName == "French" }
            
            #expect(usStats != nil, "Should have statistics for US layout")
            #expect(frenchStats != nil, "Should have statistics for French layout")
            
            #expect(usStats?.switchCount == 2, "US should have 2 switches")
            #expect(frenchStats?.switchCount == 1, "French should have 1 switch")
        }
        
        @Test("Clear all data removes records")
        func testClearAllData() async throws {
            let mockDefaults = MockUserDefaults()
            let analytics = LayoutAnalytics(defaults: mockDefaults)
            
            // Track some data
            analytics.startTracking(layout: "US", app: "Xcode")
            analytics.stopTracking()
            
            // Verify data exists
            var records = try loadRecordsFromDefaults(mockDefaults)
            #expect(records.count == 1, "Should have one record before clearing")
            
            // Clear all data
            analytics.clearAllData()
            
            // Verify data is gone
            records = try loadRecordsFromDefaults(mockDefaults)
            #expect(records.count == 0, "Should have no records after clearing")
        }
        
        // Helper function to load records from mock UserDefaults
        private func loadRecordsFromDefaults(_ defaults: UserDefaults) throws -> [LayoutUsageRecord] {
            guard let data = defaults.data(forKey: "layoutUsageRecords") else {
                return []
            }
            return try JSONDecoder().decode([LayoutUsageRecord].self, from: data)
        }
    }
}
