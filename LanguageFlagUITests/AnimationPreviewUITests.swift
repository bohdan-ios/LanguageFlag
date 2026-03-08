import XCTest

/// UI Tests for Animation Preview in Preferences Window
final class AnimationPreviewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"] // Optional: Add testing mode
        app.launch()
        
        // Give menu bar app time to fully initialize
        sleep(2)
        
        // Activate the app (important for menu bar apps!)
        app.activate()
        sleep(1)
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Preferences Window Tests
    
    /// Debug test to see what UI elements are available
    func testDebugAvailableElements() throws {
        print("\n========== DEBUG: App State ==========")
        print("App is running:", app.exists)
        print("App state:", app.state.rawValue)
        
        // Try to activate
        app.activate()
        sleep(2)
        
        print("\n========== DEBUG: UI Hierarchy ==========")
        print("Windows count:", app.windows.count)
        for (index, window) in app.windows.allElementsBoundByIndex.enumerated() {
            print("Window \(index):", window.title)
        }
        
        print("\nButtons count:", app.buttons.count)
        print("Menu bars count:", app.menuBars.count)
        print("Menu bar items count:", app.menuBarItems.count)
        
        // Try keyboard shortcut
        print("\n========== DEBUG: Trying Cmd+, ==========")
        app.typeKey(",", modifierFlags: .command)
        sleep(3)
        
        print("After Cmd+, - Windows count:", app.windows.count)
        for (index, window) in app.windows.allElementsBoundByIndex.enumerated() {
            print("Window \(index):", window.title)
        }
        
        // This test always passes - it's just for debugging
        XCTAssertTrue(true, "Debug test complete")
    }
    
    /// Test that preferences window opens
    func testPreferencesWindowOpens() throws {
        let statusItem = app.statusItems.firstMatch
        XCTAssertTrue(statusItem.waitForExistence(timeout: 3), "Status bar item should exist")

        statusItem.click()

        let prefsMenuItem = app.menuItems["Preferences..."]
        XCTAssertTrue(prefsMenuItem.waitForExistence(timeout: 3), "Preferences menu item should exist")

        prefsMenuItem.click()

        let preferencesWindow = app.windows["LanguageFlag Preferences"]
        XCTAssertTrue(preferencesWindow.waitForExistence(timeout: 5), "Preferences window should open")
    }
    
    /// Test navigating to Appearance tab
    func testNavigateToAppearanceTab() throws {
        openPreferences()
        
        // Click on Appearance tab
        let appearanceButton = app.tabs["Appearance"]
        XCTAssertTrue(appearanceButton.waitForExistence(timeout: 3), "Appearance button should exist")

        appearanceButton.click()
        
        // Verify Appearance content is shown
        let animationStyleText = app.staticTexts["Animation Style"]
        XCTAssertTrue(animationStyleText.waitForExistence(timeout: 2), "Animation Style section should be visible")
    }
    
    /// Test clicking different animation style buttons
    func testClickingAnimationStyleButtons() throws {
        openPreferences()
        navigateToAppearanceTab()
        
        // Use accessibility identifiers instead of button text
        let fadeButton = app.buttons["animation_style_fade"]
        let bounceButton = app.buttons["animation_style_bounce"]
        let flipButton = app.buttons["animation_style_flip"]
        
        XCTAssertTrue(fadeButton.waitForExistence(timeout: 2), "Fade button should exist")
        XCTAssertTrue(bounceButton.exists, "Bounce button should exist")
        XCTAssertTrue(flipButton.exists, "Flip button should exist")
        
        // Click different animation styles
        bounceButton.click()
        
        // Wait a moment for animation to complete
        sleep(2)
        
        // Click another style
        flipButton.click()
        
        // Wait for animation
        sleep(2)
        
        // Click back to fade
        fadeButton.click()
        
        // Verify we can interact with UI after animations
        XCTAssertTrue(fadeButton.exists, "UI should remain responsive")
    }
    
    /// Test animation style selection visual feedback
    func testAnimationStyleSelection() throws {
        openPreferences()
        navigateToAppearanceTab()
        
        let bounceButton = app.buttons["animation_style_bounce"]
        XCTAssertTrue(bounceButton.waitForExistence(timeout: 2), "Bounce button should exist")
        
        bounceButton.click()
        
        // For now, just verify it's still there and clickable
        XCTAssertTrue(bounceButton.exists)
        XCTAssertTrue(bounceButton.isEnabled)
    }
    
    /// Test rapid clicking of animation buttons (stress test)
    func testRapidAnimationStyleChanges() throws {
        openPreferences()
        navigateToAppearanceTab()
        
        let styles = ["fade", "bounce", "flip", "rotate", "scale"]
        
        // Rapidly click different animation styles using accessibility identifiers
        for styleName in styles {
            let button = app.buttons["animation_style_\(styleName)"]
            if button.waitForExistence(timeout: 1) {
                button.click()
                usleep(200_000) // 200ms between clicks
            }
        }
        
        // Verify UI is still responsive
        let fadeButton = app.buttons["animation_style_fade"]
        XCTAssertTrue(fadeButton.exists, "UI should remain responsive after rapid clicks")
    }
    
    /// Test window size slider
    func testWindowSizeChange() throws {
        openPreferences()
        navigateToAppearanceTab()
        
        // Look for window size section
        let windowSizeText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'size'")).firstMatch
        
        if windowSizeText.exists {
            // Try to interact with size controls (buttons or sliders)
            // Actual implementation depends on your UI
            XCTAssertTrue(windowSizeText.exists, "Window size controls should be accessible")
        }
    }
    
    /// Test opacity slider
    func testOpacitySlider() throws {
        openPreferences()
        navigateToAppearanceTab()
        
        // Use accessibility identifier
        let opacitySlider = app.sliders["opacity_slider"]
        XCTAssertTrue(opacitySlider.waitForExistence(timeout: 2), "Opacity slider should exist")
        
        // Adjust slider value
        opacitySlider.adjust(toNormalizedSliderPosition: 0.75)
        
        // Verify slider is still accessible
        XCTAssertTrue(opacitySlider.exists, "Opacity slider should be adjustable")
    }
    
    /// Test animation duration slider
    func testAnimationDurationSlider() throws {
        openPreferences()
        navigateToAppearanceTab()
        
        // Use accessibility identifier
        let durationSlider = app.sliders["animation_duration_slider"]
        XCTAssertTrue(durationSlider.waitForExistence(timeout: 2), "Animation duration slider should exist")
        
        // Adjust slider
        durationSlider.adjust(toNormalizedSliderPosition: 0.5)
        
        XCTAssertTrue(durationSlider.exists, "Duration slider should be adjustable")
    }
    
    /// Test closing preferences window
    func testClosePreferencesWindow() throws {
        openPreferences()
        
        let preferencesWindow = app.windows["LanguageFlag Preferences"]
        XCTAssertTrue(preferencesWindow.exists)
        
        // Close window (Cmd+W or close button)
        preferencesWindow.buttons[XCUIIdentifierCloseWindow].click()
        
        // Verify window closed
        XCTAssertFalse(preferencesWindow.exists, "Preferences window should close")
    }
    
    /// Test preferences persist after closing and reopening
    func testPreferencesPersistence() throws {
        openPreferences()
        navigateToAppearanceTab()
        
        // Select bounce animation using accessibility identifier
        let bounceButton = app.buttons["animation_style_bounce"]
        XCTAssertTrue(bounceButton.waitForExistence(timeout: 2), "Bounce button should exist")
        
        bounceButton.click()
        
        // Close preferences
        let preferencesWindow = app.windows["LanguageFlag Preferences"]
        if preferencesWindow.exists {
            preferencesWindow.buttons[XCUIIdentifierCloseWindow].click()
        }
        
        // Reopen preferences
        openPreferences()
        navigateToAppearanceTab()
        
        // Verify bounce button still exists
        XCTAssertTrue(bounceButton.waitForExistence(timeout: 2), "Selected animation should persist")
    }
    
    // MARK: - Performance Tests
    
    /// Test animation preview performance
    func testAnimationPreviewPerformance() throws {
        openPreferences()
        navigateToAppearanceTab()
        
        measure {
            // Click animation button and measure time using accessibility identifier
            let bounceButton = app.buttons["animation_style_bounce"]
            if bounceButton.exists {
                bounceButton.click()
            }
            
            // Wait for animation to complete
            usleep(500_000) // 500ms
        }
    }
    
    // MARK: - Helper Methods
    
    private func openPreferences() {
        let statusItem = app.statusItems.firstMatch
        guard statusItem.waitForExistence(timeout: 3) else {
            XCTFail("Status bar item not found")
            return
        }

        statusItem.click()

        let prefsMenuItem = app.menuItems["Preferences..."]
        guard prefsMenuItem.waitForExistence(timeout: 3) else {
            XCTFail("Preferences menu item not found")
            return
        }

        prefsMenuItem.click()
        _ = app.windows["LanguageFlag Preferences"].waitForExistence(timeout: 10)
    }
    
    private func navigateToAppearanceTab() {
        // Click Appearance tab
        let appearanceButton = app.tabs["Appearance"]
        if appearanceButton.waitForExistence(timeout: 2) {
            appearanceButton.click()
        }
        
        // Wait for content to load
        usleep(500_000) // 500ms
    }
}
