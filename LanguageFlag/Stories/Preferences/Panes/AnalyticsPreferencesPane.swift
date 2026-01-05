import SwiftUI

/// Analytics preferences pane for usage tracking and statistics
struct AnalyticsPreferencesPane: View {

    // MARK: - Variables
    @State private var statistics: [LayoutStatistics] = []
    @State private var appStatistics: [AppLayoutStatistics] = []
    @State private var appPreferences: [AppLayoutPreference] = []
    @State private var isEnabled = LayoutAnalytics.shared.isEnabled
    @State private var smartSuggestionsEnabled = SmartLayoutSuggestions.shared.isEnabled
    @State private var totalSwitches = 0
    @State private var totalTime: TimeInterval = 0
    @State private var selectedTab = 0

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                togglesSection

                Divider()
                
                if isEnabled {
                    enabledContent
                } else {
                    disabledContent
                }
                
                Spacer().frame(height: 20)
            }
            .padding()
        }
        .onAppear { refreshStatistics() }
        .onReceive(NotificationCenter.default.publisher(for: .analyticsDidChange)) { _ in
            refreshStatistics()
        }
    }
    
    private var togglesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Enable usage analytics", isOn: $isEnabled)
                .help("Track keyboard layout usage patterns")
                .onChange(of: isEnabled) { newValue in
                    LayoutAnalytics.shared.isEnabled = newValue
                    if newValue { refreshStatistics() }
                }

            Toggle("Enable smart layout suggestions", isOn: $smartSuggestionsEnabled)
                .help("Learn your layout preferences per app and suggest layouts automatically")
                .onChange(of: smartSuggestionsEnabled) { newValue in
                    SmartLayoutSuggestions.shared.isEnabled = newValue
                    refreshStatistics()
                }
        }
    }
    
    private var enabledContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            summarySection

            Divider()

            tabPicker

            statisticsContent

            Divider()

            clearDataButton
        }
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)

            HStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Switches")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(totalSwitches)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Time Tracked")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(formatTotalTime(totalTime))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var tabPicker: some View {
        Picker("", selection: $selectedTab) {
            Text("By Layout").tag(0)

            Text("By App").tag(1)

            if smartSuggestionsEnabled {
                Text("Learned Preferences").tag(2)
            }
        }
        .pickerStyle(.segmented)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var statisticsContent: some View {
        if selectedTab == 0 {
            layoutStatisticsSection
        } else if selectedTab == 1 {
            appStatisticsSection
        } else if selectedTab == 2 {
            learnedPreferencesSection
        }
    }
    
    private var layoutStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Layout Usage")
                    .font(.headline)

                Spacer()

                if !statistics.isEmpty {
                    Button("Refresh") { refreshStatistics() }
                        .buttonStyle(.borderless)
                }
            }

            if statistics.isEmpty {
                Text("No usage data yet. Start switching layouts to see statistics.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(statistics) { stat in
                        LayoutStatisticRow(statistic: stat)
                    }
                }
            }
        }
    }
    
    private var appStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Usage by Application")
                    .font(.headline)

                Spacer()

                if !appStatistics.isEmpty {
                    Button("Refresh") { refreshStatistics() }
                        .buttonStyle(.borderless)
                }
            }

            if appStatistics.isEmpty {
                Text("No usage data yet. Start switching layouts to see statistics.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(appStatistics) { stat in
                        AppStatisticRow(statistic: stat)
                    }
                }
            }
        }
    }
    
    private var learnedPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Learned App Preferences")
                    .font(.headline)

                Spacer()

                if !appPreferences.isEmpty {
                    Button("Refresh") { refreshStatistics() }
                        .buttonStyle(.borderless)
                }
            }

            Text("The app learns which layouts you prefer in different applications")
                .font(.caption)
                .foregroundColor(.secondary)

            if appPreferences.isEmpty {
                Text("No learned preferences yet. Use different layouts in various apps to build preferences.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(appPreferences) { pref in
                        AppPreferenceRow(preference: pref)
                    }
                }
            }
        }
    }
    
    private var clearDataButton: some View {
        HStack {
            Spacer()

            Button("Clear All Data") {
                LayoutAnalytics.shared.clearAllData()
                refreshStatistics()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
    }
    
    private var disabledContent: some View {
        Text("Analytics are currently disabled. Enable to start tracking layout usage.")
            .font(.body)
            .foregroundColor(.secondary)
            .padding(.vertical, 20)
    }
}

// MARK: - Private
private extension AnalyticsPreferencesPane {
    
    func refreshStatistics() {
        statistics = LayoutAnalytics.shared.getStatistics()
        appStatistics = LayoutAnalytics.shared.getAppStatistics()
        appPreferences = SmartLayoutSuggestions.shared.getAppPreferences()
        totalSwitches = LayoutAnalytics.shared.getTotalSwitchCount()
        totalTime = LayoutAnalytics.shared.getTotalTrackedTime()
    }

    func formatTotalTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "< 1m"
        }
    }
}
