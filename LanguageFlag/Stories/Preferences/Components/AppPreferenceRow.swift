import SwiftUI

/// Row displaying learned app layout preferences with confidence indicator
struct AppPreferenceRow: View {

    // MARK: - Variables
    private let preference: AppLayoutPreference

    private var confidenceColor: Color {
        if preference.confidenceScore >= 0.8 {
            return .green
        } else if preference.confidenceScore >= 0.6 {
            return .orange
        } else {
            return .gray
        }
    }
    
    // MARK: - Init
    init(preference: AppLayoutPreference) {
        self.preference = preference
    }

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerRow

            confidenceBar

            if preference.layoutPreferences.count > 1 {
                layoutBreakdown
            }
        }
        .padding(.vertical, 6)
    }
    
    private var headerRow: some View {
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
    }
    
    private var confidenceBar: some View {
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
    }
    
    private var layoutBreakdown: some View {
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
