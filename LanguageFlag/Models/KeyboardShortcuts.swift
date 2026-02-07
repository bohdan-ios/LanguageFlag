import Foundation

struct KeyboardShortcut {

    let key: String
    let description: String
    let modifier: String?

    var displayText: String {
        if let modifier = modifier {
            return "\(modifier)+\(key): \(description)"
        }
        return "\(key): \(description)"
    }
}

final class KeyboardShortcutsProvider {

    static let shared = KeyboardShortcutsProvider()

    private let shortcutsDatabase: [String: [KeyboardShortcut]] = [
        // English
        "U.S.": [
            KeyboardShortcut(key: "@", description: "At sign", modifier: "Shift+2"),
            KeyboardShortcut(key: "#", description: "Hash/Pound", modifier: "Shift+3"),
            KeyboardShortcut(key: "$", description: "Dollar", modifier: "Shift+4")
        ],

        // Russian
        "Russian": [
            KeyboardShortcut(key: "Ё", description: "Yo character", modifier: nil),
            KeyboardShortcut(key: "Ъ", description: "Hard sign", modifier: nil),
            KeyboardShortcut(key: "Э", description: "E character", modifier: nil)
        ],

        // German
        "German": [
            KeyboardShortcut(key: "Ä", description: "A umlaut", modifier: "Shift+Ö"),
            KeyboardShortcut(key: "Ö", description: "O umlaut", modifier: "Shift+;"),
            KeyboardShortcut(key: "Ü", description: "U umlaut", modifier: "Shift+["),
            KeyboardShortcut(key: "ß", description: "Eszett/Sharp S", modifier: "-")
        ],

        // French
        "French": [
            KeyboardShortcut(key: "É", description: "E acute", modifier: "Shift+2"),
            KeyboardShortcut(key: "È", description: "E grave", modifier: "Shift+7"),
            KeyboardShortcut(key: "Ç", description: "C cedilla", modifier: "Shift+9"),
            KeyboardShortcut(key: "À", description: "A grave", modifier: "Shift+0")
        ],

        // Spanish
        "Spanish": [
            KeyboardShortcut(key: "Ñ", description: "N tilde", modifier: ";"),
            KeyboardShortcut(key: "Á", description: "A acute", modifier: "´+A"),
            KeyboardShortcut(key: "¿", description: "Inverted question", modifier: "Shift+="),
            KeyboardShortcut(key: "¡", description: "Inverted exclamation", modifier: "Shift+1")
        ],

        // Ukrainian
        "Ukrainian": [
            KeyboardShortcut(key: "Є", description: "Ukrainian Ye", modifier: nil),
            KeyboardShortcut(key: "І", description: "Ukrainian I", modifier: nil),
            KeyboardShortcut(key: "Ї", description: "Ukrainian Yi", modifier: nil),
            KeyboardShortcut(key: "Ґ", description: "Ukrainian G", modifier: nil)
        ],

        // Polish
        "Polish": [
            KeyboardShortcut(key: "Ą", description: "A with ogonek", modifier: "Alt+A"),
            KeyboardShortcut(key: "Ć", description: "C acute", modifier: "Alt+C"),
            KeyboardShortcut(key: "Ę", description: "E with ogonek", modifier: "Alt+E"),
            KeyboardShortcut(key: "Ł", description: "L stroke", modifier: "Alt+L")
        ],

        // Czech
        "Czech": [
            KeyboardShortcut(key: "Č", description: "C caron", modifier: "Alt+C"),
            KeyboardShortcut(key: "Ř", description: "R caron", modifier: "Alt+R"),
            KeyboardShortcut(key: "Š", description: "S caron", modifier: "Alt+S"),
            KeyboardShortcut(key: "Ž", description: "Z caron", modifier: "Alt+Z")
        ]
    ]

    func shortcuts(for layout: String) -> [KeyboardShortcut] {
        // Try exact match first
        if let shortcuts = shortcutsDatabase[layout] {
            return shortcuts
        }

        // Try partial match (e.g., "Russian - PC" matches "Russian")
        for (key, value) in shortcutsDatabase where layout.contains(key) {
            return value
        }

        // Return empty array if no match
        return []
    }

    func hasShortcuts(for layout: String) -> Bool {
        !shortcuts(for: layout).isEmpty
    }
}
