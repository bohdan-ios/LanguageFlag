import SwiftUI

/// About preferences pane displaying app information and mini-game
struct AboutPreferencesPane: View {

    
    // MARK: - Properties
    
    private let appName = "LanguageFlag"
    private let appVersion: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "Version \(version) (Build \(build))"
    }()
    
    // MARK: - Views
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                appInfoSection
                
                Divider()
                
                gameSectionHeader
                
                SubwayGameView()
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Subviews
    
    private var appInfoSection: some View {
        VStack(spacing: 12) {
            // App Icon
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 128, height: 128)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            } else {
                // Fallback icon
                Image(systemName: "flag.circle.fill")
                    .resizable()
                    .frame(width: 128, height: 128)
                    .foregroundColor(.accentColor)
            }
            
            // App Name
            Text(appName)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            // Version
            Text(appVersion)
                .font(.callout)
                .foregroundColor(.secondary)
            
            // Tagline
            Text("Beautiful keyboard layout switching for macOS")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Links
            HStack(spacing: 20) {
                Button {
                    // Could open GitHub/website
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "link.circle")
                        Text("Website")
                    }
                }
                .buttonStyle(.link)
                
                Button {
                    // Could open GitHub
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
        .padding(.top, 20)
    }
    
    private var gameSectionHeader: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "gamecontroller.fill")
                    .foregroundColor(.accentColor)
                Text("Subway Runner Mini-Game")
                    .font(.headline)
            }
            
            Text("Take a break and test your reflexes!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

struct AboutPreferencesPane_Previews: PreviewProvider {

    static var previews: some View {
        AboutPreferencesPane()
            .frame(width: 650, height: 500)
    }
}
