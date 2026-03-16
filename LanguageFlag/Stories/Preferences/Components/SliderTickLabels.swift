import SwiftUI

/// Renders tick labels precisely aligned to slider track positions.
///
/// `trackInset` is the distance from the slider view edge to the track endpoint
/// (approximately half the macOS slider thumb width, ~10–11 pt).
struct SliderTickLabels: View {

    // MARK: - Variables
    let labels: [String]
    var trackInset: CGFloat = 11

    // MARK: - Views
    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width - 2 * trackInset
            let count = CGFloat(labels.count - 1)

            ZStack(alignment: .topLeading) {
                ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                    let fraction = count > 0 ? CGFloat(index) / count : 0

                    Text(label)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .position(x: trackInset + fraction * trackWidth, y: 7)
                }
            }
        }
        .frame(height: 14)
    }
}
