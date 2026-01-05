# LanguageFlag - New Features

## Preferences Window

Access the preferences window via the menu bar icon: **⚙️ Preferences...**  
Or use the keyboard shortcut: **⌘,**

### General Tab

**Display Duration** (0.5s - 5.0s)
- Customize how long the language indicator stays visible
- Default: 1.0 second

**Display Position**
- Choose where the indicator appears on screen
- Options: Top/Center/Bottom × Left/Center/Right
- Default: Bottom Center

**Window Size**
- Small (200×124), Medium (250×155), or Large (300×186)
- Default: Medium

**Show in Menu Bar**
- Toggle to display current layout in the menu bar
- Shows flag icon for quick reference

### Appearance Tab

**Opacity** (50% - 100%)
- Control the transparency of the indicator window
- Default: 95%

**Animation Style**
- Fade, Slide, or Scale animations
- Default: Fade

**Animation Speed** (0.1s - 1.0s)
- Control how fast the show/hide animations play
- Default: 0.3 seconds

**Live Preview**
- See your appearance settings in real-time

### Shortcuts Tab

**Show Keyboard Shortcuts**
- Enable to display common keyboard shortcuts for the current layout
- Automatically detects layout-specific special characters
- Supported layouts:
  - English (U.S.)
  - Russian
  - German (Ä, Ö, Ü, ß)
  - French (É, È, Ç, À)
  - Spanish (Ñ, ¿, ¡)
  - Ukrainian (Є, І, Ї, Ґ)
  - Polish (Ą, Ć, Ę, Ł)
  - Czech (Č, Ř, Š, Ž)

## Technical Implementation

### Architecture
- **SwiftUI** for modern, native macOS preferences UI
- **UserDefaults** for persistent settings storage
- **Combine** via `@Published` properties for reactive updates
- **Protocol-oriented design** for keyboard shortcuts

### Files Added
```
LanguageFlag/
├── Models/
│   ├── UserPreferences.swift       # Settings management
│   └── KeyboardShortcuts.swift     # Shortcuts database
└── Preferences/
    ├── PreferencesView.swift       # SwiftUI preferences UI
    └── PreferencesWindowController.swift  # Window management
```

### Files Modified
```
LanguageFlag/Helpers/
├── StatusBarManager.swift          # Added preferences menu item
├── StatusBarMenuBuilder.swift      # Added preferences action
└── LanguageWindowController.swift  # Integrated user preferences
```

## Usage Examples

### Customizing Display
1. Open **Preferences**
2. Adjust **Display Duration** to 2.0 seconds for longer visibility
3. Change **Display Position** to "Top Center"
4. Select **Large** window size for better visibility

### Changing Appearance
1. Go to **Appearance** tab
2. Set **Opacity** to 80% for subtle display
3. Choose **Scale** animation for smooth effect
4. Increase **Animation Speed** to 0.5s for slower transitions

### Enable Shortcuts
1. Navigate to **Shortcuts** tab
2. Toggle **Show keyboard shortcuts** ON
3. Switch keyboard layouts to see layout-specific shortcuts

## Reset to Defaults

Use the **Reset to Defaults** button in the General tab to restore all settings to their original values.

