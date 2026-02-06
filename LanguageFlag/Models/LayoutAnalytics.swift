import Foundation
import AppKit

struct LayoutUsageRecord: Codable {

    let layoutName: String
    let appName: String
    let startTime: Date
    let endTime: Date

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
}

struct LayoutStatistics: Identifiable {

    let id = UUID()
    let layoutName: String
    var totalDuration: TimeInterval
    var switchCount: Int
    var lastUsed: Date?

    var formattedDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        let seconds = Int(totalDuration) % 60

        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }

    var percentage: Double = 0.0
}

struct AppLayoutStatistics: Identifiable {
    let id = UUID()
    let appName: String
    var layoutUsage: [String: TimeInterval] // layoutName -> total duration
    var totalDuration: TimeInterval
    var switchCount: Int

    var mostUsedLayout: String? {
        layoutUsage.max(by: { $0.value < $1.value })?.key
    }

    var formattedDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60

        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm", minutes)
        } else {
            return "< 1m"
        }
    }
}

extension Notification.Name {
    static let analyticsDidChange = Notification.Name("analyticsDidChange")
}

final class LayoutAnalytics {

    static let shared = LayoutAnalytics()

    private let defaults = UserDefaults.standard
    private let recordsKey = "layoutUsageRecords"
    private let analyticsEnabledKey = "analyticsEnabled"

    private var currentLayoutName: String?
    private var currentAppName: String?
    private var currentLayoutStartTime: Date?

    private init() {
        // Load analytics enabled preference (default: true)
        if defaults.object(forKey: analyticsEnabledKey) == nil {
            defaults.set(true, forKey: analyticsEnabledKey)
        }
    }

    // MARK: - Public API

    var isEnabled: Bool {
        get { defaults.bool(forKey: analyticsEnabledKey) }
        set {
            defaults.set(newValue, forKey: analyticsEnabledKey)
            NotificationCenter.default.post(name: .analyticsDidChange, object: nil)
        }
    }

    func startTracking(layout: String, app: String? = nil) {
        guard isEnabled else { return }

        // End previous session if exists
        endCurrentSession()

        currentLayoutName = layout
        currentAppName = app ?? getCurrentAppName()
        currentLayoutStartTime = Date()

        // Record for smart suggestions
        if let appName = currentAppName {
            SmartLayoutSuggestions.shared.recordUsage(layout: layout, app: appName)
        }
    }

    func stopTracking() {
        endCurrentSession()
    }

    func getStatistics() -> [LayoutStatistics] {
        let records = loadRecords()

        // Group records by layout
        var statsDict: [String: LayoutStatistics] = [:]

        for record in records {
            if var stats = statsDict[record.layoutName] {
                stats.totalDuration += record.duration
                stats.switchCount += 1
                if let lastUsed = stats.lastUsed {
                    stats.lastUsed = max(lastUsed, record.endTime)
                } else {
                    stats.lastUsed = record.endTime
                }
                statsDict[record.layoutName] = stats
            } else {
                statsDict[record.layoutName] = LayoutStatistics(
                    layoutName: record.layoutName,
                    totalDuration: record.duration,
                    switchCount: 1,
                    lastUsed: record.endTime
                )
            }
        }

        // Calculate total duration for percentages
        let totalDuration = statsDict.values.reduce(0) { $0 + $1.totalDuration }

        // Calculate percentages and sort by total duration
        var statistics = statsDict.values.map { stats -> LayoutStatistics in
            var mutableStats = stats
            mutableStats.percentage = totalDuration > 0 ? (stats.totalDuration / totalDuration) * 100 : 0
            return mutableStats
        }

        statistics.sort { $0.totalDuration > $1.totalDuration }

        return statistics
    }

    func getTotalSwitchCount() -> Int {
        loadRecords().count
    }

    func getTotalTrackedTime() -> TimeInterval {
        loadRecords().reduce(0) { $0 + $1.duration }
    }

    func getAppStatistics() -> [AppLayoutStatistics] {
        let records = loadRecords()

        // Group records by app
        var appStats: [String: (layoutUsage: [String: TimeInterval], switchCount: Int)] = [:]

        for record in records {
            if var stats = appStats[record.appName] {
                stats.layoutUsage[record.layoutName, default: 0] += record.duration
                stats.switchCount += 1
                appStats[record.appName] = stats
            } else {
                appStats[record.appName] = (
                    layoutUsage: [record.layoutName: record.duration],
                    switchCount: 1
                )
            }
        }

        // Convert to AppLayoutStatistics array
        var statistics = appStats.map { appName, stats -> AppLayoutStatistics in
            let totalDuration = stats.layoutUsage.values.reduce(0, +)
            return AppLayoutStatistics(
                appName: appName,
                layoutUsage: stats.layoutUsage,
                totalDuration: totalDuration,
                switchCount: stats.switchCount
            )
        }

        statistics.sort { $0.totalDuration > $1.totalDuration }

        return statistics
    }

    func clearAllData() {
        defaults.removeObject(forKey: recordsKey)
        currentLayoutName = nil
        currentAppName = nil
        currentLayoutStartTime = nil
        NotificationCenter.default.post(name: .analyticsDidChange, object: nil)
    }

    // MARK: - Private

    private func endCurrentSession() {
        guard
            isEnabled,
            let layoutName = currentLayoutName,
            let appName = currentAppName,
            let startTime = currentLayoutStartTime
        else {
            return
        }

        let endTime = Date()
        let record = LayoutUsageRecord(
            layoutName: layoutName,
            appName: appName,
            startTime: startTime,
            endTime: endTime
        )

        saveRecord(record)

        currentLayoutName = nil
        currentAppName = nil
        currentLayoutStartTime = nil
    }

    private func getCurrentAppName() -> String {
        if let app = NSWorkspace.shared.frontmostApplication {
            return app.localizedName ?? "Unknown"
        }
        return "Unknown"
    }

    private func saveRecord(_ record: LayoutUsageRecord) {
        var records = loadRecords()
        records.append(record)

        if let encoded = try? JSONEncoder().encode(records) {
            defaults.set(encoded, forKey: recordsKey)
            NotificationCenter.default.post(name: .analyticsDidChange, object: nil)
        }
    }

    private func loadRecords() -> [LayoutUsageRecord] {
        guard
            let data = defaults.data(forKey: recordsKey),
            let records = try? JSONDecoder().decode([LayoutUsageRecord].self, from: data)
        else {
            return []
        }
        return records
    }
}
