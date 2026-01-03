// swiftlint:disable all

import SwiftUI

struct PreferencesView: View {

    @ObservedObject var preferences = UserPreferences.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralPreferencesView(preferences: preferences)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
                .tag(0)

            AppearancePreferencesView(preferences: preferences)
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
                .tag(1)

            ShortcutsPreferencesView(preferences: preferences)
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
                .tag(2)

            AnalyticsPreferencesView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .tag(3)

            LayoutGroupsPreferencesView()
                .tabItem {
                    Label("Groups", systemImage: "folder")
                }
                .tag(4)
        }
        .padding(.top, 8)
        .frame(width: 500, height: 500)
    }
}

// MARK: - General Preferences
struct GeneralPreferencesView: View {

    @ObservedObject var preferences: UserPreferences

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Display Duration
                VStack(alignment: .leading, spacing: 8) {
                    Text("Display Duration")
                        .font(.headline)
                    HStack {
                        Slider(value: $preferences.displayDuration, in: 0.5...5.0, step: 0.5)
                        Text(String(format: "%.1fs", preferences.displayDuration))
                            .frame(width: 40, alignment: .trailing)
                    }
                    Text("How long the language indicator stays visible")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                // Display Position
                VStack(alignment: .leading, spacing: 8) {
                    Text("Display Position")
                        .font(.headline)

                    PositionPickerView(selectedPosition: $preferences.displayPosition)
                        .frame(height: 160)

                    Text("Click a position to place the indicator on your screen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                // Window Size
                VStack(alignment: .leading, spacing: 8) {
                    Text("Window Size")
                        .font(.headline)

                    HStack(spacing: 12) {
                        Text("Small")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Slider(
                            value: Binding(
                                get: { Double(WindowSize.allCases.firstIndex(of: preferences.windowSize) ?? 1) },
                                set: { preferences.windowSize = WindowSize.allCases[Int($0)] }
                            ),
                            in: 0...2,
                            step: 1
                        )

                        Text("Large")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(preferences.windowSize.description)
                            .frame(width: 60, alignment: .trailing)
                            .foregroundColor(.primary)
                    }

                    Text("Size of the language indicator window")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                // Menu Bar
                Toggle("Show current layout in menu bar", isOn: $preferences.showInMenuBar)
                    .help("Display the current keyboard layout in the menu bar")

                Spacer()
                    .frame(height: 20)

                // Reset Button
                HStack {
                    Spacer()
                    Button("Reset to Defaults") {
                        preferences.resetToDefaults()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }
}

// MARK: - Appearance Preferences
struct AppearancePreferencesView: View {

    @ObservedObject var preferences: UserPreferences

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                    // Opacity
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Opacity")
                            .font(.headline)
                        HStack {
                            Slider(value: $preferences.opacity, in: 0.5...1.0, step: 0.05)
                            Text(String(format: "%.0f%%", preferences.opacity * 100))
                                .frame(width: 45, alignment: .trailing)
                        }
                        Text("Transparency of the indicator window")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Animation Style
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Animation Style")
                            .font(.headline)
                        Picker("", selection: $preferences.animationStyle) {
                            ForEach(AnimationStyle.allCases, id: \.self) { style in
                                Text(style.description).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        Text("How the indicator appears and disappears")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Animation Duration
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Animation Speed")
                            .font(.headline)
                        HStack {
                            Slider(value: $preferences.animationDuration, in: 0.1...1.0, step: 0.1)
                            Text(String(format: "%.1fs", preferences.animationDuration))
                                .frame(width: 40, alignment: .trailing)
                        }
                        Text("Duration of show/hide animations")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Preview
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Preview")
//                            .font(.headline)
//                        HStack {
//                            Spacer()
//                            RoundedRectangle(cornerRadius: 16)
//                                .fill(Color.gray.opacity(preferences.opacity))
//                                .frame(width: 150, height: 93)
//                                .overlay(
//                                    VStack {
//                                        Image(systemName: "flag.fill")
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(height: 40)
//                                        Text("Preview")
//                                            .font(.caption)
//                                    }
//                                    .foregroundColor(.white)
//                                )
//                            Spacer()
//                        }
//                        .padding(.vertical)
//                    }

                    Spacer()
                        .frame(height: 20)
                }
                .padding()
            }
    }
}

// MARK: - Shortcuts Preferences
struct ShortcutsPreferencesView: View {

    @ObservedObject var preferences: UserPreferences

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                    // Show Shortcuts
                    Toggle("Show keyboard shortcuts for current layout", isOn: $preferences.showShortcuts)
                        .help("Display common keyboard shortcuts when switching layouts")

                    Divider()

                    // Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Keyboard Shortcuts Feature")
                            .font(.headline)

                        Text("When enabled, the indicator will show the most common keyboard shortcuts for the selected layout:")
                            .font(.body)
                            .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Label("Special character combinations", systemImage: "keyboard")
                            Label("Language-specific shortcuts", systemImage: "character.textbox")
                            Label("Dead keys and diacritics", systemImage: "character.cursor.ibeam")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading)

                        Text("Note: Shortcuts are automatically detected based on your keyboard layout configuration.")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.top, 8)
                    }

                    Spacer()
                        .frame(height: 20)
                }
                .padding()
            }
    }
}

// MARK: - Position Picker View
struct PositionPickerView: View {

    @Binding var selectedPosition: DisplayPosition
    @State private var isDragging = false

    // 16:10 laptop screen aspect ratio (scaled down to fit preferences window)
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

    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            GeometryReader { geometry in
                ZStack {
                    // Screen background (laptop display)
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

                    // Grid of position buttons
                    VStack(spacing: cellSpacing) {
                        // Top row
                        HStack(spacing: cellSpacing) {
                            PositionButton(
                                position: .topLeft,
                                selectedPosition: $selectedPosition,
                                isDragging: $isDragging,
                                width: cellWidth,
                                height: cellHeight
                            )
                            PositionButton(
                                position: .topCenter,
                                selectedPosition: $selectedPosition,
                                isDragging: $isDragging,
                                width: cellWidth,
                                height: cellHeight
                            )
                            PositionButton(
                                position: .topRight,
                                selectedPosition: $selectedPosition,
                                isDragging: $isDragging,
                                width: cellWidth,
                                height: cellHeight
                            )
                        }

                        // Center row
                        HStack(spacing: cellSpacing) {
                            PositionButton(
                                position: .centerLeft,
                                selectedPosition: $selectedPosition,
                                isDragging: $isDragging,
                                width: cellWidth,
                                height: cellHeight
                            )
                            PositionButton(
                                position: .center,
                                selectedPosition: $selectedPosition,
                                isDragging: $isDragging,
                                width: cellWidth,
                                height: cellHeight
                            )
                            PositionButton(
                                position: .centerRight,
                                selectedPosition: $selectedPosition,
                                isDragging: $isDragging,
                                width: cellWidth,
                                height: cellHeight
                            )
                        }

                        // Bottom row
                        HStack(spacing: cellSpacing) {
                            PositionButton(
                                position: .bottomLeft,
                                selectedPosition: $selectedPosition,
                                isDragging: $isDragging,
                                width: cellWidth,
                                height: cellHeight
                            )
                            PositionButton(
                                position: .bottomCenter,
                                selectedPosition: $selectedPosition,
                                isDragging: $isDragging,
                                width: cellWidth,
                                height: cellHeight
                            )
                            PositionButton(
                                position: .bottomRight,
                                selectedPosition: $selectedPosition,
                                isDragging: $isDragging,
                                width: cellWidth,
                                height: cellHeight
                            )
                        }
                    }
                    .padding(cellSpacing * 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDragging = true
                                let position = positionForLocation(value.location, in: geometry.size)
                                print("❤️ DragGesture, position: \(position)")
                                selectedPosition = position
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                }
                .contentShape(Rectangle())
            }
            .frame(width: screenWidth, height: screenHeight)

            Spacer()
        }
        .frame(height: screenHeight)
    }

    private func positionForLocation(_ location: CGPoint, in size: CGSize) -> DisplayPosition {
        let padding = cellSpacing * 2

        // Adjust for padding
        let adjustedX = location.x - padding
        let adjustedY = location.y - padding

        // Calculate which cell we're in
        // We need to account for both cell width/height AND spacing between cells
        var col = 0
        var row = 0

        // Calculate column
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

        // Calculate row
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

        // Clamp to valid range
        col = min(2, max(0, col))
        row = min(2, max(0, row))

        return positions[row][col]
    }
}

// MARK: - Position Button
struct PositionButton: View {

    let position: DisplayPosition
    @Binding var selectedPosition: DisplayPosition
    @Binding var isDragging: Bool
    let width: CGFloat
    let height: CGFloat
    @State private var isHovered = false

    var isSelected: Bool {
        selectedPosition == position
    }

    var body: some View {
        ZStack {
            // Cell background
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? Color.accentColor.opacity(0.25) : (isHovered && !isDragging ? Color.gray.opacity(0.2) : Color.clear))

            // Selected indicator (small window representation)
            if isSelected {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor)
                    .frame(width: width * 0.4, height: height * 0.5)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
        .frame(width: width, height: height)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering

            // Update position while dragging and hovering
            if isDragging && hovering {
                selectedPosition = position
            }
        }
    }
}

// MARK: - Analytics Preferences
struct AnalyticsPreferencesView: View {

    @State private var statistics: [LayoutStatistics] = []
    @State private var appStatistics: [AppLayoutStatistics] = []
    @State private var appPreferences: [AppLayoutPreference] = []
    @State private var isEnabled = LayoutAnalytics.shared.isEnabled
    @State private var smartSuggestionsEnabled = SmartLayoutSuggestions.shared.isEnabled
    @State private var totalSwitches = 0
    @State private var totalTime: TimeInterval = 0
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Analytics Toggle
                Toggle("Enable usage analytics", isOn: $isEnabled)
                    .help("Track keyboard layout usage patterns")
                    .onChange(of: isEnabled) { newValue in
                        LayoutAnalytics.shared.isEnabled = newValue
                        if newValue {
                            refreshStatistics()
                        }
                    }

                // Smart Suggestions Toggle
                Toggle("Enable smart layout suggestions", isOn: $smartSuggestionsEnabled)
                    .help("Learn your layout preferences per app and suggest layouts automatically")
                    .onChange(of: smartSuggestionsEnabled) { newValue in
                        SmartLayoutSuggestions.shared.isEnabled = newValue
                        refreshStatistics()
                    }

                Divider()

                if isEnabled {
                    // Summary Statistics
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

                    Divider()

                    // Tab Picker
                    Picker("", selection: $selectedTab) {
                        Text("By Layout").tag(0)
                        Text("By App").tag(1)
                        if smartSuggestionsEnabled {
                            Text("Learned Preferences").tag(2)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 8)

                    // Statistics based on selected tab
                    if selectedTab == 0 {
                        // Layout Statistics
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Layout Usage")
                                    .font(.headline)

                                Spacer()

                                if !statistics.isEmpty {
                                    Button("Refresh") {
                                        refreshStatistics()
                                    }
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
                    } else if selectedTab == 1 {
                        // App Statistics
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Usage by Application")
                                    .font(.headline)

                                Spacer()

                                if !appStatistics.isEmpty {
                                    Button("Refresh") {
                                        refreshStatistics()
                                    }
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
                    } else if selectedTab == 2 {
                        // Learned Preferences
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Learned App Preferences")
                                    .font(.headline)

                                Spacer()

                                if !appPreferences.isEmpty {
                                    Button("Refresh") {
                                        refreshStatistics()
                                    }
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

                    Divider()

                    // Clear Data Button
                    HStack {
                        Spacer()
                        Button("Clear All Data") {
                            LayoutAnalytics.shared.clearAllData()
                            refreshStatistics()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                } else {
                    Text("Analytics are currently disabled. Enable to start tracking layout usage.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 20)
                }

                Spacer()
                    .frame(height: 20)
            }
            .padding()
        }
        .onAppear {
            refreshStatistics()
        }
    }

    private func refreshStatistics() {
        statistics = LayoutAnalytics.shared.getStatistics()
        appStatistics = LayoutAnalytics.shared.getAppStatistics()
        appPreferences = SmartLayoutSuggestions.shared.getAppPreferences()
        totalSwitches = LayoutAnalytics.shared.getTotalSwitchCount()
        totalTime = LayoutAnalytics.shared.getTotalTrackedTime()
    }

    private func formatTotalTime(_ time: TimeInterval) -> String {
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

// MARK: - App Statistic Row
struct AppStatisticRow: View {

    let statistic: AppLayoutStatistics
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 12)

                    Text(statistic.appName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(statistic.formattedDuration)
                            .font(.body)
                            .foregroundColor(.secondary)

                        if let mostUsed = statistic.mostUsedLayout {
                            Text(mostUsed)
                                .font(.caption)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(statistic.layoutUsage.sorted(by: { $0.value > $1.value }), id: \.key) { layoutName, duration in
                        HStack {
                            Text(layoutName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 24)

                            Spacer()

                            Text(formatDuration(duration))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.05))
        )
    }

    private func formatDuration(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60

        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm", minutes)
        } else {
            return "< 1m"
        }
    }
}

// MARK: - Layout Statistic Row
struct LayoutStatisticRow: View {

    let statistic: LayoutStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(statistic.layoutName)
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()

                Text(statistic.formattedDuration)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 8) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.accentColor)
                            .frame(width: geometry.size.width * CGFloat(statistic.percentage / 100), height: 6)
                    }
                }
                .frame(height: 6)

                Text(String(format: "%.1f%%", statistic.percentage))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 45, alignment: .trailing)
            }

            HStack {
                Text("\(statistic.switchCount) switches")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let lastUsed = statistic.lastUsed {
                    Spacer()
                    Text("Last: \(formatRelativeTime(lastUsed))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }

    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - App Preference Row
struct AppPreferenceRow: View {

    let preference: AppLayoutPreference

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(preference.appName)
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()

                if let preferred = preference.preferredLayout {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(preferred)
                            .font(.caption)
                            .foregroundColor(.accentColor)

                        Text(String(format: "%.0f%% confidence", preference.confidenceScore * 100))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Progress bar showing confidence
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(confidenceColor)
                        .frame(width: geometry.size.width * CGFloat(preference.confidenceScore), height: 4)
                }
            }
            .frame(height: 4)

            // Layout breakdown (if multiple layouts)
            if preference.layoutPreferences.count > 1 {
                HStack(spacing: 12) {
                    ForEach(preference.layoutPreferences.sorted(by: { $0.value > $1.value }), id: \.key) { layout, count in
                        HStack(spacing: 4) {
                            Text(layout)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("(\(count))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }

    private var confidenceColor: Color {
        if preference.confidenceScore >= 0.8 {
            return .green
        } else if preference.confidenceScore >= 0.6 {
            return .orange
        } else {
            return .gray
        }
    }
}

// MARK: - Layout Groups Preferences
struct LayoutGroupsPreferencesView: View {

    @State private var groups: [LayoutGroup] = []
    @State private var activeGroup: LayoutGroup?
    @State private var showingAddGroup = false
    @State private var editingGroup: LayoutGroup?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text("Layout Groups")
                        .font(.headline)

                    Spacer()

                    Button(action: {
                        showingAddGroup = true
                    }) {
                        Label("New Group", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                }

                Text("Organize your keyboard layouts into groups for quick switching")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Divider()

                // Active Group
                if let active = activeGroup {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Active Group")
                            .font(.headline)

                        HStack {
                            Circle()
                                .fill(Color(hex: active.color))
                                .frame(width: 12, height: 12)

                            Text(active.name)
                                .font(.body)
                                .fontWeight(.medium)

                            Spacer()

                            Button("Deactivate") {
                                LayoutGroupManager.shared.activeGroup = nil
                                refreshGroups()
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(.secondary)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: active.color).opacity(0.1))
                        )
                    }

                    Divider()
                }

                // Groups List
                VStack(alignment: .leading, spacing: 12) {
                    Text("All Groups")
                        .font(.headline)

                    if groups.isEmpty {
                        Text("No groups yet. Create your first group to organize layouts.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 20)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(groups) { group in
                                LayoutGroupRow(
                                    group: group,
                                    isActive: activeGroup?.id == group.id,
                                    onActivate: {
                                        LayoutGroupManager.shared.activeGroup = group
                                        refreshGroups()
                                    },
                                    onEdit: {
                                        editingGroup = group
                                    },
                                    onDelete: {
                                        LayoutGroupManager.shared.deleteGroup(group)
                                        refreshGroups()
                                    }
                                )
                            }
                        }
                    }
                }

                Spacer()
                    .frame(height: 20)
            }
            .padding()
        }
        .onAppear {
            refreshGroups()
        }
        .sheet(isPresented: $showingAddGroup) {
            LayoutGroupEditor(group: nil, onSave: { group in
                LayoutGroupManager.shared.saveGroup(group)
                showingAddGroup = false
                refreshGroups()
            })
        }
        .sheet(item: $editingGroup) { group in
            LayoutGroupEditor(group: group, onSave: { updatedGroup in
                LayoutGroupManager.shared.saveGroup(updatedGroup)
                editingGroup = nil
                refreshGroups()
            })
        }
    }

    private func refreshGroups() {
        groups = LayoutGroupManager.shared.getGroups()
        activeGroup = LayoutGroupManager.shared.activeGroup
    }
}

// MARK: - Layout Group Row
struct LayoutGroupRow: View {

    let group: LayoutGroup
    let isActive: Bool
    let onActivate: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: group.color))
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text("\(group.layouts.count) layout\(group.layouts.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !isActive {
                Button("Activate") {
                    onActivate()
                }
                .buttonStyle(.borderless)
                .foregroundColor(.accentColor)
            }

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

// MARK: - Layout Group Editor
struct LayoutGroupEditor: View {

    let group: LayoutGroup?
    let onSave: (LayoutGroup) -> Void

    @State private var name: String
    @State private var selectedLayouts: Set<String>
    @State private var selectedColor: String
    @Environment(\.dismiss) private var dismiss

    private let availableLayouts: [String]
    private let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00"
    ]

    init(group: LayoutGroup?, onSave: @escaping (LayoutGroup) -> Void) {
        self.group = group
        self.onSave = onSave
        self.availableLayouts = LayoutGroupManager.shared.getAvailableLayouts()

        _name = State(initialValue: group?.name ?? "")
        _selectedLayouts = State(initialValue: Set(group?.layouts ?? []))
        _selectedColor = State(initialValue: group?.color ?? "#007AFF")
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(group == nil ? "New Layout Group" : "Edit Layout Group")
                .font(.headline)

            // Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Group Name")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("e.g., Work, Personal", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            // Color
            VStack(alignment: .leading, spacing: 8) {
                Text("Color")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    ForEach(colorOptions, id: \.self) { color in
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
            }

            // Layouts
            VStack(alignment: .leading, spacing: 8) {
                Text("Layouts")
                    .font(.caption)
                    .foregroundColor(.secondary)

                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(availableLayouts, id: \.self) { layout in
                            Toggle(layout, isOn: Binding(
                                get: { selectedLayouts.contains(layout) },
                                set: { isOn in
                                    if isOn {
                                        selectedLayouts.insert(layout)
                                    } else {
                                        selectedLayouts.remove(layout)
                                    }
                                }
                            ))
                            .toggleStyle(.checkbox)
                        }
                    }
                }
                .frame(height: 150)
            }

            // Buttons
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Save") {
                    let newGroup = LayoutGroup(
                        id: group?.id ?? UUID(),
                        name: name,
                        layouts: Array(selectedLayouts),
                        color: selectedColor
                    )
                    onSave(newGroup)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || selectedLayouts.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400, height: 450)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: 1
        )
    }
}

// MARK: - Preview
struct PreferencesView_Previews: PreviewProvider {

    static var previews: some View {
        PreferencesView()
    }
}
