# UI Testing Guide for Animation Preview

## 🎯 Overview

This guide shows you how to add and run UI tests for the animation preview feature in your preferences window.

---

## 📋 Setup Checklist

### ✅ Step 1: Create UI Test Target

1. **In Xcode**: File → New → Target...
2. Select: **"UI Testing Bundle"** (macOS)
3. Name: `LanguageFlagUITests`
4. Product Name: `LanguageFlagUITests`
5. Click **Finish**

### ✅ Step 2: Configure UI Test Target

In your UI test target settings:
- Set **Test Host**: Select your main app
- Set **Target Application**: Your app bundle ID
- Ensure **Automatically** is selected for "Test Host"

### ✅ Step 3: Add Test File

Add `AnimationPreviewUITests.swift` to your UI test target (not the unit test target!)

---

## 🎨 Improve Testability with Accessibility Identifiers

### Add Identifiers to Your SwiftUI Views

Update `AppearancePreferencesPane.swift`:

```swift
func animationStyleButton(for style: AnimationStyle) -> some View {
    Button {
        preferences.animationStyle = style
    } label: {
        Text(style.description)
            // ... existing styling ...
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier("animation_style_\(style.rawValue)") // ← Add this!
}
```

Update other controls:

```swift
// Opacity slider
Slider(value: $preferences.opacity, in: 0.5...1.0, step: 0.05)
    .accessibilityIdentifier("opacity_slider")

// Window size buttons/picker
// Add identifier to each size option
.accessibilityIdentifier("window_size_\(size.rawValue)")

// Animation duration slider
Slider(value: $preferences.animationDuration, in: 0.1...1.0, step: 0.1)
    .accessibilityIdentifier("animation_duration_slider")
```

---

## 🧪 Running UI Tests

### Option 1: Run All UI Tests
```bash
Cmd + U (runs all tests including UI)
```

### Option 2: Run Only UI Tests
```bash
# In Test Navigator (Cmd + 6)
Right-click "LanguageFlagUITests" → Run
```

### Option 3: Run Specific Test
```bash
# Click the ◆ icon next to specific test method
```

### Option 4: Command Line
```bash
xcodebuild test \
  -scheme LanguageFlag \
  -destination 'platform=macOS' \
  -only-testing:LanguageFlagUITests
```

---

## 🎬 Recording UI Tests

Xcode can **record** your interactions to generate UI test code!

### How to Record:

1. Open `AnimationPreviewUITests.swift`
2. Place cursor inside a test method
3. Click the **Record button** (red circle) at bottom of editor
4. **Your app launches** - interact with it!
5. Click through preferences, click animation buttons
6. Click **Stop** when done
7. Xcode generates the UI test code! ✨

### Example Recorded Code:
```swift
func testRecorded() {
    let menuBarsQuery = app.menuBars
    menuBarsQuery.menuItems["Preferences…"].click()
    
    let button = app.buttons["Bounce"]
    button.click()
}
```

---

## 🔍 UI Test Structure

### Anatomy of a UI Test:

```swift
func testSomething() {
    // 1. ARRANGE: Set up test conditions
    openPreferences()
    navigateToAppearanceTab()
    
    // 2. ACT: Perform the action
    let bounceButton = app.buttons["Bounce"]
    bounceButton.click()
    
    // 3. ASSERT: Verify the result
    XCTAssertTrue(bounceButton.exists)
}
```

### Common XCUIElement Queries:

```swift
// Buttons
app.buttons["Button Title"]
app.buttons.matching(identifier: "button_id")

// Text fields
app.textFields["Field Name"]

// Sliders
app.sliders.firstMatch
app.sliders["slider_id"]

// Windows
app.windows["Window Title"]

// Static text
app.staticTexts["Text Content"]

// Groups (containers)
app.groups["group_id"]
```

---

## 📊 What Can UI Tests Verify?

### ✅ **Element Existence**
```swift
XCTAssertTrue(button.exists, "Button should exist")
XCTAssertFalse(window.exists, "Window should be closed")
```

### ✅ **Element State**
```swift
XCTAssertTrue(button.isEnabled, "Button should be enabled")
XCTAssertTrue(button.isHittable, "Button should be clickable")
```

### ✅ **Element Properties**
```swift
XCTAssertEqual(textField.value as? String, "Expected Text")
XCTAssertEqual(slider.normalizedSliderPosition, 0.5)
```

### ✅ **Timing**
```swift
XCTAssertTrue(element.waitForExistence(timeout: 5))
```

### ❌ **What UI Tests CAN'T Verify Directly**
- Internal state (use unit tests for this)
- Actual animations playing (can only verify elements appear/disappear)
- Performance (use XCTest performance tests)
- Visual appearance (pixel-perfect matching requires snapshot testing)

---

## 🎯 Best Practices for UI Testing

### 1. **Use Accessibility Identifiers**
```swift
// In SwiftUI
.accessibilityIdentifier("my_button")

// In test
app.buttons["my_button"]
```

### 2. **Wait for Elements**
```swift
let element = app.buttons["My Button"]
XCTAssertTrue(element.waitForExistence(timeout: 5))
```

### 3. **Use Helper Methods**
```swift
private func openPreferences() {
    // Reusable logic
}

private func navigateToAppearanceTab() {
    // Reusable navigation
}
```

### 4. **Keep Tests Independent**
```swift
override func setUp() {
    // Reset app state
    app.launchArguments = ["--uitesting", "--reset-preferences"]
}
```

### 5. **Test User Flows, Not Implementation**
```swift
// ✅ Good: Test what user does
func testUserSelectsAnimation() {
    openPreferences()
    selectAnimation("Bounce")
    verifyPreviewShown()
}

// ❌ Bad: Test internal details
func testAnimationStylePropertyChanges() {
    // This should be a unit test
}
```

---

## 🐛 Debugging UI Tests

### **Common Issues:**

#### Issue 1: Element Not Found
```swift
// Problem:
app.buttons["Bounce"].click() // ❌ Fails

// Solution: Wait for element
let button = app.buttons["Bounce"]
XCTAssertTrue(button.waitForExistence(timeout: 5))
button.click() // ✅ Works
```

#### Issue 2: Wrong Element Query
```swift
// Try different queries:
app.buttons["Title"]
app.buttons.matching(identifier: "id")
app.descendants(matching: .button)["Title"]
```

#### Issue 3: Timing Issues
```swift
// Add explicit waits
sleep(1) // seconds
usleep(500_000) // microseconds (500ms)
Thread.sleep(forTimeInterval: 0.5)
```

### **Debug Tools:**

#### 1. **Print UI Hierarchy**
```swift
print(app.debugDescription)
```

#### 2. **Pause and Inspect**
```swift
// Add breakpoint and use lldb:
po app.buttons
po app.staticTexts
```

#### 3. **Accessibility Inspector**
- Xcode → Open Developer Tool → Accessibility Inspector
- Hover over UI elements to see their accessibility properties

---

## 📈 Test Coverage

### **Tests Created: 12 UI Tests**

| Test | Purpose |
|------|---------|
| testPreferencesWindowOpens | Window opens correctly |
| testNavigateToAppearanceTab | Navigation works |
| testClickingAnimationStyleButtons | Buttons are clickable |
| testAnimationStyleSelection | Selection state works |
| testRapidAnimationStyleChanges | Stress test |
| testWindowSizeChange | Size controls work |
| testOpacitySlider | Opacity slider works |
| testAnimationDurationSlider | Duration slider works |
| testClosePreferencesWindow | Window closes |
| testPreferencesPersistence | Settings persist |
| testAnimationPreviewPerformance | Performance test |

---

## 🚀 Quick Start

### **1. Add UI Test Target** (5 minutes)
- File → New → Target → UI Testing Bundle

### **2. Add Test File** (1 minute)
- Add `AnimationPreviewUITests.swift` to target

### **3. Add Accessibility IDs** (10 minutes)
- Update SwiftUI views with `.accessibilityIdentifier()`

### **4. Run Tests** (2 minutes)
- Press Cmd + U
- Watch app launch and tests run automatically!

### **5. Record More Tests** (5 minutes)
- Use record button to capture interactions
- Generate more test cases

---

## 💡 Tips & Tricks

### **Speed Up Tests**
```swift
// Disable animations for faster tests
app.launchArguments = ["--uitesting", "--disable-animations"]
```

### **Reset State Between Tests**
```swift
override func setUp() {
    app.launchArguments = ["--uitesting", "--reset"]
    app.launch()
}
```

### **Test in Different States**
```swift
app.launchEnvironment = ["LANGUAGE": "fr_FR"]
app.launchArguments = ["--dark-mode"]
```

### **Parallel Testing**
- Edit Scheme → Test → Options
- Enable "Execute in parallel"
- Tests run faster on multi-core systems

---

## 📊 Expected Results

### **After Setup:**
```
Test Suite 'LanguageFlagUITests' started
✓ testPreferencesWindowOpens (2.5s)
✓ testNavigateToAppearanceTab (1.8s)
✓ testClickingAnimationStyleButtons (3.2s)
✓ testAnimationStyleSelection (2.1s)
✓ testRapidAnimationStyleChanges (4.5s)
✓ testWindowSizeChange (2.0s)
✓ testOpacitySlider (1.9s)
✓ testAnimationDurationSlider (1.8s)
✓ testClosePreferencesWindow (1.5s)
✓ testPreferencesPersistence (3.8s)
✓ testAnimationPreviewPerformance (1.2s)

Total: 12 tests, 12 passed, 0 failed
Time: ~26 seconds
```

---

## 🎊 Summary

### **You Now Have:**
- ✅ UI test target setup guide
- ✅ 12 comprehensive UI tests
- ✅ Accessibility identifier guide
- ✅ Recording instructions
- ✅ Debugging tips
- ✅ Best practices

### **Next Steps:**
1. Add UI test target in Xcode
2. Add accessibility identifiers to views
3. Run the tests
4. Record more tests for additional scenarios

---

## 📚 Further Reading

- [Apple UI Testing Guide](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/09-ui_testing.html)
- [XCUIElement Documentation](https://developer.apple.com/documentation/xctest/xcuielement)
- [Accessibility for Testing](https://developer.apple.com/documentation/accessibility)

---

**Ready to test your UI! 🎉**
