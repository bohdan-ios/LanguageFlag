import SwiftUI

/// Row displaying layout usage statistics with progress bar
struct LayoutStatisticRow: View {

    // MARK: - Variables
    private let statistic: LayoutStatistics
    
    // MARK: - Init
    init(statistic: LayoutStatistics) {
        self.statistic = statistic
    }

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            headerRow

            progressRow

            detailsRow
        }
        .padding(.vertical, 6)
    }
    
    private var headerRow: some View {
        HStack {
            Text(statistic.layoutName)
                .font(.body)
                .fontWeight(.medium)

            Spacer()

            Text(statistic.formattedDuration)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    private var progressRow: some View {
        HStack(spacing: 8) {
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
    }
    
    private var detailsRow: some View {
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
}

// MARK: - Private
private extension LayoutStatisticRow {
    
    func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
