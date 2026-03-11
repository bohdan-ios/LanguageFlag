import SwiftUI

/// About preferences pane displaying app information with vibrant animations
struct AboutPreferencesPane: View {

    // MARK: - Properties

    private let appName = "LanguageFlag"
    private let appVersion: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "Version \(version) (Build \(build))"
    }()

    @State private var isHovering = false
    @State private var rotationDegrees: Double = 0

    // MARK: - Views

    var body: some View {
        ZStack {
            animatedGradientBackground

            ScrollView {
                VStack(spacing: 24) {
                    appInfoSection

                    Spacer()
                }
                .padding()
            }
        }
    }
}

// MARK: - Animated Gradient Background
private extension AboutPreferencesPane {

    var animatedGradientBackground: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let angle = Angle.degrees(elapsed.truncatingRemainder(dividingBy: 360) * 8)

            AngularGradient(
                colors: [
                    Color.purple.opacity(0.3),
                    Color.blue.opacity(0.25),
                    Color.teal.opacity(0.3),
                    Color.pink.opacity(0.25),
                    Color.purple.opacity(0.3)
                ],
                center: .center,
                angle: angle
            )
            .blur(radius: 60)
            .ignoresSafeArea()
        }
    }
}

// MARK: - App Info Section
private extension AboutPreferencesPane {

    var appInfoSection: some View {
        VStack(spacing: 16) {
            // App Icon with orbiting flags
            ZStack {
                orbitingFlagsView

                interactiveAppIcon
            }
            .frame(width: 200, height: 200)

            // App Name
            Text(appName)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)

            // Tagline
            Text("Beautiful keyboard layout switching for macOS")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Version — keycap style
            Text(appVersion)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)

            // Links
            linksSection
        }
        .padding(.top, 20)
    }
}

// MARK: - Orbiting Flags
private extension AboutPreferencesPane {

    /// Flags that orbit around the app icon in a slow circle
    var orbitingFlagsView: some View {
        let flags = ["🇺🇸", "🇫🇷", "🇩🇪", "🇯🇵", "🇰🇷", "🇺🇦", "🇪🇸", "🇧🇷"]
        let radius: CGFloat = 82

        return TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let baseAngle = elapsed.truncatingRemainder(dividingBy: 360) * 12 // degrees per second

            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                for (index, flag) in flags.enumerated() {
                    let offsetAngle = baseAngle + Double(index) * (360.0 / Double(flags.count))
                    let radians = offsetAngle * .pi / 180

                    let x = center.x + radius * cos(radians)
                    let y = center.y + radius * sin(radians)

                    let text = Text(flag).font(.system(size: 20))
                    context.opacity = 0.7
                    context.draw(
                        context.resolve(text),
                        at: CGPoint(x: x, y: y),
                        anchor: .center
                    )
                }
            }
        }
    }
}

// MARK: - Interactive App Icon
private extension AboutPreferencesPane {

    var interactiveAppIcon: some View {
        ZStack {
            // Glow ring behind icon
            Circle()
                .fill(Color.accentColor.opacity(isHovering ? 0.4 : 0.15))
                .frame(width: 140, height: 140)
                .blur(radius: isHovering ? 20 : 12)

            Group {
                if let appIcon = NSImage(named: "AppIcon") {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                } else {
                    Image(systemName: "flag.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.accentColor)
                }
            }
            .rotation3DEffect(.degrees(rotationDegrees), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(isHovering ? 1.08 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHovering)
        }
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                rotationDegrees += 360
            }
        }
    }
}

// MARK: - Links
private extension AboutPreferencesPane {

    var linksSection: some View {
        HStack(spacing: 20) {
            Button {
                if let url = URL(string: "https://bohdan-ios.github.io/languageflag-website/") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "link.circle")
                    Text("Website")
                }
            }
            .buttonStyle(.link)

            Button {
                if let url = URL(string: "https://github.com/bohdan-ios/LanguageFlag") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                    Text("Source")
                }
            }
            .buttonStyle(.link)
        }
        .font(.caption)
    }
}

// MARK: - Preview
struct AboutPreferencesPane_Previews: PreviewProvider {

    static var previews: some View {
        AboutPreferencesPane()
            .frame(width: 650, height: 500)
    }
}
