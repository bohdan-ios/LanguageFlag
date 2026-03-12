# Adding Accessibility Identifiers - Quick Reference

## 🎯 Why Add Accessibility Identifiers?

Accessibility identifiers make your UI tests:
- ✅ **More reliable** - Not dependent on visible text
- ✅ **Easier to maintain** - Change button text without breaking tests
- ✅ **Language-independent** - Works in any locale
- ✅ **More specific** - Uniquely identify elements

---

## 📝 How to Add Identifiers

### **SwiftUI** (Your Current Stack)

```swift
// Buttons
Button("Save") {
    // action
}
.accessibilityIdentifier("save_button")

// Text Fields
TextField("Enter name", text: $name)
    .accessibilityIdentifier("name_field")

// Sliders
Slider(value: $opacity, in: 0...1)
    .accessibilityIdentifier("opacity_slider")

// Any View
Text("Hello")
    .accessibilityIdentifier("greeting_text")
```

### **AppKit/NSView** (If Needed)

```swift
button.accessibilityIdentifier = "my_button"
textField.accessibilityIdentifier = "my_textfield"
```

---

## 🎨 Update Your AppearancePreferencesPane

Here's how to add identifiers to your existing code:

### **File**: `AppearancePreferencesPane.swift`

```swift
import SwiftUI

struct AppearancePreferencesPane: View {
    @ObservedObject private var preferences: UserPreferences
    
    var body: some View {
        content
            .accessibilityIdentifier("appearance_pane") // ← Identify the whole pane
    }
    
    // MARK: - Opacity Section
    
    private var opacitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Opacity")
                .font(.headline)
                .accessibilityIdentifier("opacity_title") // ← Section title

            HStack {
                Slider(value: $preferences.opacity, in: 0.5...1.0, step: 0.05)
                    .accessibilityIdentifier("opacity_slider") // ← THE SLIDER

                Text(String(format: "%.0f%%", preferences.opacity * 100))
                    .frame(width: 45, alignment: .trailing)
                    .accessibilityIdentifier("opacity_value") // ← Value display
            }

            Text("Transparency of the language window")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .contain) // Makes group accessible
        .accessibilityIdentifier("opacity_section")
    }
    
    // MARK: - Animation Style Section
    
    private var animationStyleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Animation Style")
                .font(.headline)
                .accessibilityIdentifier("animation_style_title") // ← Section title

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
                ForEach(AnimationStyle.allCases, id: \.self) { style in
                    animationStyleButton(for: style)
                }
            }
            .accessibilityIdentifier("animation_style_grid") // ← Grid container

            Text("How the indicator appears and disappears")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityIdentifier("animation_style_section")
    }
    
    // MARK: - Animation Style Button
    
    private func animationStyleButton(for style: AnimationStyle) -> some View {
        Button {
            preferences.animationStyle = style
        } label: {
            Text(style.description)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(preferences.animationStyle == style ? Color.accentColor : Color.gray.opacity(0.15))
                .foregroundColor(preferences.animationStyle == style ? .white : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("animation_style_\(style.rawValue)") // ← EACH BUTTON
        .accessibilityLabel(style.description) // ← Screen reader support
        .accessibilityHint("Select \(style.description) animation") // ← What it does
    }
    
    // MARK: - Animation Duration Section
    
    private var animationSpeedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Animation Speed")
                .font(.headline)
                .accessibilityIdentifier("animation_speed_title")

            HStack {
                Slider(value: $preferences.animationDuration, in: 0.1...1.0, step: 0.1)
                    .accessibilityIdentifier("animation_duration_slider") // ← THE SLIDER

                Text(String(format: "%.1fs", preferences.animationDuration))
                    .frame(width: 40, alignment: .trailing)
                    .accessibilityIdentifier("animation_duration_value")
            }

            Text("Duration of show/hide animations")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityIdentifier("animation_speed_section")
    }
    
    // MARK: - Animation Behavior Section
    
    private var animationBehaviorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Animation Behavior")
                .font(.headline)
                .accessibilityIdentifier("animation_behavior_title")

            Toggle("Reset animation on layout change", isOn: $preferences.resetAnimationOnChange)
                .accessibilityIdentifier("reset_animation_toggle") // ← THE TOGGLE

            Text("When enabled, the animation restarts each time...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityIdentifier("animation_behavior_section")
    }
}
```

---

## 🔍 Complete Identifier List

### **For Animation Preview Testing:**

```swift
// Main containers
"appearance_pane"
"opacity_section"
"animation_style_section"
"animation_speed_section"
"animation_behavior_section"

// Controls
"opacity_slider"
"opacity_value"
"animation_duration_slider"
"animation_duration_value"
"reset_animation_toggle"

// Animation style buttons (one for each style)
"animation_style_fade"
"animation_style_slide"
"animation_style_scale"
"animation_style_pixelate"
"animation_style_blur"
"animation_style_flip"
"animation_style_bounce"
"animation_style_rotate"
"animation_style_swing"
"animation_style_elastic"
"animation_style_hologram"
"animation_style_energyPortal"
"animation_style_digitalMaterialize"
"animation_style_liquidRipple"
"animation_style_inkDiffusion"
"animation_style_vhsGlitch"
```

---

## 🧪 Using Identifiers in Tests

### **Before** (Fragile):
```swift
// ❌ Breaks if button text changes or is localized
let button = app.buttons["Bounce"]
button.click()
```

### **After** (Robust):
```swift
// ✅ Works regardless of displayed text
let button = app.buttons["animation_style_bounce"]
button.click()
```

---

## 🎯 Naming Conventions

### **Good Identifier Names:**
```swift
// ✅ Descriptive, unique, lowercase with underscores
"save_button"
"email_text_field"
"animation_style_bounce"
"opacity_slider"
```

### **Bad Identifier Names:**
```swift
// ❌ Too generic, unclear, or using spaces
"button1"
"slider"
"The Save Button"
"btn"
```

### **Pattern:**
```
<component_type>_<specific_name>
<section>_<component>_<variant>

Examples:
button_save
slider_opacity
animation_style_bounce
```

---

## 📊 Testing Priority

### **High Priority** (Add First):
1. ✅ Animation style buttons
2. ✅ Opacity slider
3. ✅ Animation duration slider
4. ✅ Reset animation toggle

### **Medium Priority** (Add Later):
5. ⏳ Window size controls
6. ⏳ Display position controls
7. ⏳ Section titles

### **Low Priority** (Optional):
8. ⏳ Helper text
9. ⏳ Containers
10. ⏳ Spacers

---

## 🚀 Quick Implementation

### **Minimum Changes Needed:**

Just add these 4 identifiers for basic animation testing:

```swift
// 1. Animation style buttons (in animationStyleButton function)
.accessibilityIdentifier("animation_style_\(style.rawValue)")

// 2. Opacity slider
.accessibilityIdentifier("opacity_slider")

// 3. Duration slider
.accessibilityIdentifier("animation_duration_slider")

// 4. Reset toggle
.accessibilityIdentifier("reset_animation_toggle")
```

That's it! You can now test animation previews!

---

## 🎬 Before & After Example

### **Before:**
```swift
func animationStyleButton(for style: AnimationStyle) -> some View {
    Button { ... } label: {
        Text(style.description)
            .frame(maxWidth: .infinity)
            .background(...)
    }
    .buttonStyle(.plain)
    // No identifier ❌
}
```

### **After:**
```swift
func animationStyleButton(for style: AnimationStyle) -> some View {
    Button { ... } label: {
        Text(style.description)
            .frame(maxWidth: .infinity)
            .background(...)
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier("animation_style_\(style.rawValue)") // ✅ Added!
}
```

---

## ✅ Checklist

- [ ] Add identifier to animation style buttons
- [ ] Add identifier to opacity slider
- [ ] Add identifier to duration slider
- [ ] Add identifier to reset toggle
- [ ] (Optional) Add identifiers to sections
- [ ] (Optional) Add identifiers to all controls
- [ ] Test identifiers work in UI tests
- [ ] Verify accessibility with Accessibility Inspector

---

## 🎊 Done!

After adding identifiers, your UI tests will be:
- ✅ More reliable
- ✅ Easier to maintain
- ✅ Faster to write
- ✅ Language-independent

**Time investment: ~10 minutes**
**Benefit: Robust UI testing forever!** 🚀
