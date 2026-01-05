import SwiftUI

/// Row displaying app usage statistics with expandable details
struct AppStatisticRow: View {

    // MARK: - Variables
    @State private var isExpanded = false

    private let statistic: AppLayoutStatistics
    
    // MARK: - Init
    init(statistic: AppLayoutStatistics) {
        self.statistic = statistic
    }

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerButton

            if isExpanded {
                expandedContent
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.05))
        )
    }
    
    private var headerButton: some View {
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
    }
    
    private var expandedContent: some View {
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

// MARK: - Private
private extension AppStatisticRow {
    
    func formatDuration(_ time: TimeInterval) -> String {
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
