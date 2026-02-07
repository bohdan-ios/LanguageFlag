//
//  SmartLayoutSuggestions.swift
//  LanguageFlag
//
//  Created by Claude on 01/02/2026.
//

import Foundation

struct AppLayoutPreference: Codable, Identifiable {

    let id = UUID()
    let appName: String
    var layoutPreferences: [String: Int] // layoutName -> usage count
    var lastUsedLayout: String?

    var preferredLayout: String? {
        layoutPreferences.max(by: { $0.value < $1.value })?.key
    }

    var confidenceScore: Double {
        guard !layoutPreferences.isEmpty else { return 0.0 }
        let total = layoutPreferences.values.reduce(0, +)
        let maxCount = layoutPreferences.values.max() ?? 0
        return Double(maxCount) / Double(total)
    }

    enum CodingKeys: String, CodingKey {

        case appName, layoutPreferences, lastUsedLayout
    }
}

struct TimeBasedPattern: Codable {

    let hour: Int // 0-23
    var layoutUsage: [String: Int]

    var preferredLayout: String? {
        layoutUsage.max(by: { $0.value < $1.value })?.key
    }
}

final class SmartLayoutSuggestions {

    static let shared = SmartLayoutSuggestions()

    private let defaults = UserDefaults.standard
    private let appPreferencesKey = "appLayoutPreferences"
    private let timeBasedPatternsKey = "timeBasedPatterns"
    private let enabledKey = "smartSuggestionsEnabled"
    private let minUsageForSuggestion = 3 // Minimum times used before suggesting

    private init() {
        // Initialize with smart suggestions enabled by default
        if defaults.object(forKey: enabledKey) == nil {
            defaults.set(true, forKey: enabledKey)
        }
    }

    // MARK: - Public API

    var isEnabled: Bool {
        get { defaults.bool(forKey: enabledKey) }
        set { defaults.set(newValue, forKey: enabledKey) }
    }

    func recordUsage(layout: String, app: String) {
        guard isEnabled else { return }

        // Record app-specific preference
        recordAppPreference(layout: layout, app: app)

        // Record time-based pattern
        recordTimePattern(layout: layout)
    }

    func getSuggestion(for app: String) -> String? {
        guard isEnabled else { return nil }

        // Get app-specific suggestion
        if let appSuggestion = getAppSuggestion(for: app) {
            return appSuggestion
        }

        // Fallback to time-based suggestion
        return getTimeBasedSuggestion()
    }

    func getAppPreferences() -> [AppLayoutPreference] {
        guard
            let data = defaults.data(forKey: appPreferencesKey),
            let preferences = try? JSONDecoder().decode([String: AppLayoutPreference].self, from: data)
        else {
            return []
        }
        return Array(preferences.values).sorted { $0.confidenceScore > $1.confidenceScore }
    }

    func clearAllData() {
        defaults.removeObject(forKey: appPreferencesKey)
        defaults.removeObject(forKey: timeBasedPatternsKey)
    }

    // MARK: - Private

    private func recordAppPreference(layout: String, app: String) {
        var preferences = loadAppPreferences()

        if var appPref = preferences[app] {
            appPref.layoutPreferences[layout, default: 0] += 1
            appPref.lastUsedLayout = layout
            preferences[app] = appPref
        } else {
            preferences[app] = AppLayoutPreference(
                appName: app,
                layoutPreferences: [layout: 1],
                lastUsedLayout: layout
            )
        }

        saveAppPreferences(preferences)
    }

    private func recordTimePattern(layout: String) {
        let hour = Calendar.current.component(.hour, from: Date())
        var patterns = loadTimePatterns()

        if var pattern = patterns[hour] {
            pattern.layoutUsage[layout, default: 0] += 1
            patterns[hour] = pattern
        } else {
            patterns[hour] = TimeBasedPattern(
                hour: hour,
                layoutUsage: [layout: 1]
            )
        }

        saveTimePatterns(patterns)
    }

    private func getAppSuggestion(for app: String) -> String? {
        let preferences = loadAppPreferences()
        guard
            let appPref = preferences[app],
            let preferredLayout = appPref.preferredLayout,
            appPref.confidenceScore >= 0.6, // At least 60% confidence
            (appPref.layoutPreferences[preferredLayout] ?? 0) >= minUsageForSuggestion
        else {
            return nil
        }
        return preferredLayout
    }

    private func getTimeBasedSuggestion() -> String? {
        let hour = Calendar.current.component(.hour, from: Date())
        let patterns = loadTimePatterns()
        guard
            let pattern = patterns[hour],
            let preferredLayout = pattern.preferredLayout,
            (pattern.layoutUsage[preferredLayout] ?? 0) >= minUsageForSuggestion
        else {
            return nil
        }
        return preferredLayout
    }

    private func loadAppPreferences() -> [String: AppLayoutPreference] {
        guard
            let data = defaults.data(forKey: appPreferencesKey),
            let preferences = try? JSONDecoder().decode([String: AppLayoutPreference].self, from: data)
        else {
            return [:]
        }
        return preferences
    }

    private func saveAppPreferences(_ preferences: [String: AppLayoutPreference]) {
        if let encoded = try? JSONEncoder().encode(preferences) {
            defaults.set(encoded, forKey: appPreferencesKey)
        }
    }

    private func loadTimePatterns() -> [Int: TimeBasedPattern] {
        guard
            let data = defaults.data(forKey: timeBasedPatternsKey),
            let patterns = try? JSONDecoder().decode([Int: TimeBasedPattern].self, from: data)
        else {
            return [:]
        }
        return patterns
    }

    private func saveTimePatterns(_ patterns: [Int: TimeBasedPattern]) {
        if let encoded = try? JSONEncoder().encode(patterns) {
            defaults.set(encoded, forKey: timeBasedPatternsKey)
        }
    }
}
