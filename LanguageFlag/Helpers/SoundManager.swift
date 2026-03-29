import AppKit

final class SoundManager {

    private let preferences = UserPreferences.shared
    private let cache: [SoundEffect: NSSound]

    // MARK: - Init
    init() {
        var loaded: [SoundEffect: NSSound] = [:]

        for effect in SoundEffect.allCases {
            if
                let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav"),
                let sound = NSSound(contentsOf: url, byReference: false)
            {
                loaded[effect] = sound
            }
        }

        cache = loaded

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLayoutChange),
            name: .keyboardLayoutChanged,
            object: nil
        )
    }

    // MARK: - Public
    func previewSound(_ effect: SoundEffect) {
        play(effect)
    }
}

// MARK: - Private
private extension SoundManager {

    @objc
    func handleLayoutChange() {
        guard preferences.playSoundOnSwitch else { return }

        play(preferences.selectedSoundEffect)
    }

    func play(_ effect: SoundEffect) {
        // Copy the cached sound so it can be played even if already playing
        guard let sound = cache[effect]?.copy() as? NSSound else { return }

        sound.volume = Float(preferences.soundVolume)
        sound.play()
    }
}
