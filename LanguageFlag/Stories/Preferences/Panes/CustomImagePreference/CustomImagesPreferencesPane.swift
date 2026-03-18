import AppKit
import SwiftUI

// MARK: - View

/// Preferences pane for uploading custom flag images per keyboard layout.
struct CustomImagesPreferencesPane: View {

    @StateObject private var viewModel = CustomImagesViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding([.horizontal, .top])
                    .padding(.bottom, 12)

                Divider()

                if viewModel.isLoading {
                    loadingPlaceholder
                } else if viewModel.layouts.isEmpty {
                    emptyPlaceholder
                } else {
                    layoutList
                }
            }
        }
        .onAppear(perform: viewModel.loadLayouts)
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Custom Images")
                .font(.headline)
            Text("Replace the default flag for any active keyboard layout with your own image.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var loadingPlaceholder: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding()
            Spacer()
        }
    }

    private var emptyPlaceholder: some View {
        HStack {
            Spacer()
            Text("No active keyboard layouts found.")
                .foregroundColor(.secondary)
                .padding()
            Spacer()
        }
    }

    private var layoutList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.layouts) { entry in
                LayoutImageRow(
                    entry: entry,
                    onUpload: { viewModel.upload(layoutID: entry.id, layoutName: entry.name) },
                    onReset: { viewModel.reset(layoutID: entry.id) }
                )
                Divider()
                    .padding(.leading, 60)
            }
        }
    }
}

// MARK: - LayoutImageRow

private struct LayoutImageRow: View {

    let entry: CustomImagesViewModel.LayoutEntry
    let onUpload: () -> Void
    let onReset: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            flagPreview
            nameStack
            Spacer()
            actionButtons
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var flagPreview: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = entry.image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Color(NSColor.separatorColor).opacity(0.3)
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
            )

            if entry.hasCustom {
                customBadge
            }
        }
    }

    private var customBadge: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 13))
            .foregroundColor(.accentColor)
            .background(
                Circle()
                    .fill(Color(NSColor.windowBackgroundColor))
                    .padding(-1)
            )
            .offset(x: 4, y: -4)
    }

    private var nameStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.name)
                .font(.system(size: 13, weight: .medium))

            #if DEBUG
            Text(entry.id)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .lineLimit(1)
            #endif
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
            if entry.hasCustom {
                Button("Reset") { onReset() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .foregroundColor(.red)
                    .help("Remove custom image and restore the default flag")
            }

            Button("Upload Image") { onUpload() }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Upload a custom image for this layout")
        }
    }
}

// MARK: - Preview

struct CustomImagesPreferencesPane_Previews: PreviewProvider {

    static var previews: some View {
        CustomImagesPreferencesPane()
            .frame(width: 650, height: 505)
    }
}
