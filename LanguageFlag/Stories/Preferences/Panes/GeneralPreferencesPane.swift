import SwiftUI
import LaunchAtLogin

/// General preferences pane for display duration, position, size, and menu bar settings
struct GeneralPreferencesPane: View {

    // MARK: - Variables
    @Binding var displayPosition: DisplayPosition
    @Binding var windowSize: WindowSize
    @Binding var showInMenuBar: Bool
    @Binding var showCapsLockIndicator: Bool
    @Binding var bypassClick: Bool
    @Binding var showDockIndicator: Bool
    @Binding var playSoundOnSwitch: Bool
    @Binding var selectedSoundEffect: SoundEffect
    @Binding var soundVolume: Double

    let onReset: () -> Void
    let soundManager: SoundManager

    @State private var showResetConfirmation = false
    @State private var previewDebounceTask: Task<Void, Never>? = nil
    @State private var lastNonZeroVolume: Double = 0.7

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                displayPositionSection

                Divider()

                windowSizeSection

                Divider()

                indicatorBehaviorSection

                Spacer()
                    .frame(height: 20)

                resetButton
            }
            .padding()
        }
    }
    
    private var displayPositionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Display Position")
                .font(.headline)

            PositionPickerView(selectedPosition: $displayPosition)
                .frame(height: 160)

            Text("Click a position to place the indicator on your screen")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var windowSizeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Window Size")
                .font(.headline)

            HStack(alignment: .top, spacing: 8) {
                VStack(spacing: 2) {
                    Slider(
                        value: Binding(
                            get: { Double(WindowSize.allCases.firstIndex(of: windowSize) ?? 1) },
                            set: { windowSize = WindowSize.allCases[Int($0)] }
                        ),
                        in: 0...3,
                        step: 1
                    )

                    SliderTickLabels(labels: WindowSize.allCases.map(\.description))
                }

                Text(windowSize.description)
                    .frame(width: 95, alignment: .trailing)
                    .foregroundColor(.primary)
            }

            Text("Size of the language language window")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var indicatorBehaviorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Indicator Behavior")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                // Menu Bar Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Show current layout in menu bar")
                        Text("Display the current keyboard layout in the macOS menu bar.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("Show current layout in menu bar", isOn: $showInMenuBar)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .accessibilityIdentifier("menuBarToggle")
                }

                // Caps Lock Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Show indicator on Caps Lock change")
                        Text("Show the language window when Caps Lock is toggled.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("Show indicator on Caps Lock change", isOn: $showCapsLockIndicator)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .accessibilityIdentifier("capsLockToggle")
                }

                // Bypass Click Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bypass click")
                        Text("When enabled, clicks on the language window pass through to the window underneath.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("Bypass click", isOn: $bypassClick)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .accessibilityIdentifier("bypassClickToggle")
                }

                // Dock Indicator Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Show indicator in Dock")
                        Text("Permanently show the current language flag as the app's Dock icon.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("Show indicator in Dock", isOn: $showDockIndicator)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .accessibilityIdentifier("dockIndicatorToggle")
                }

                // Sound on Switch
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Play sound on input switch")

                        Text("Play a sound when the keyboard layout changes. Volume is relative to your system volume — 70% here means 70% of whatever your Mac is set to.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if playSoundOnSwitch {
                            HStack(spacing: 8) {
                                Picker("Sound", selection: $selectedSoundEffect) {
                                    ForEach(SoundEffect.allCases, id: \.self) { effect in
                                        Text(effect.displayName).tag(effect)
                                    }
                                }
                                .labelsHidden()
                                .pickerStyle(.menu)
                                .onChange(of: selectedSoundEffect) { _ in soundManager.previewSound(selectedSoundEffect) }

                                Button {
                                    soundManager.previewSound(selectedSoundEffect)
                                } label: {
                                    Image(systemName: "play.circle")
                                }
                                .buttonStyle(.borderless)
                                .help("Preview sound")

                                Spacer()
                            }
                            .padding(.top, 4)

                            HStack(spacing: 8) {
                                Button {
                                    if soundVolume > 0 {
                                        lastNonZeroVolume = soundVolume
                                        soundVolume = 0
                                    } else {
                                        soundVolume = lastNonZeroVolume
                                    }
                                } label: {
                                    Image(systemName: soundVolume == 0 ? "speaker.slash.fill" : "speaker.fill")
                                }
                                .buttonStyle(.borderless)
                                .foregroundColor(.secondary)
                                .help(soundVolume == 0 ? "Unmute" : "Mute")

                                Slider(value: $soundVolume, in: 0...1, step: 0.25)
                                    .frame(width: 120)
                                    .onChange(of: soundVolume) { newValue in
                                        if newValue > 0 { lastNonZeroVolume = newValue }
                                        previewDebounceTask?.cancel()
                                        previewDebounceTask = Task {
                                            try? await Task.sleep(nanoseconds: 150_000_000)
                                            guard !Task.isCancelled else { return }
                                            soundManager.previewSound(selectedSoundEffect)
                                        }
                                    }

                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 16)

                                Text("\(Int(soundVolume * 100))%")
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                                    .frame(width: 36, alignment: .leading)
                            }
                            .padding(.top, 2)
                        }
                    }

                    Spacer()

                    Toggle("Play sound on input switch", isOn: $playSoundOnSwitch)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .accessibilityIdentifier("playSoundToggle")
                        .onChange(of: playSoundOnSwitch) { newValue in
                            if newValue { soundManager.previewSound(selectedSoundEffect) }
                        }
                }

                // Launch at Login Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Launch at login")

                        Text("Automatically open the app when you log in to your Mac.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    LaunchAtLogin.Toggle()
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .accessibilityIdentifier("launchAtLoginToggle")
                }
            }
        }
    }
    
    private var resetButton: some View {
        HStack {
            #if FEATURE_RECALCULATE_FRAMES
            Button("Recalculate Window Frames") {
                NotificationCenter.default.post(name: .recalculateWindowFrames, object: nil)
            }
            .buttonStyle(.bordered)
            .help("Force recalculate all language windows for connected displays")
            #endif

            Spacer()

            Button("Reset to Defaults") {
                showResetConfirmation = true
            }
            .buttonStyle(.bordered)
            .confirmationDialog(
                "Reset all settings to their defaults?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    onReset()
                }
            }
        }
    }
}
