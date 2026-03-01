# Quick Start Guide - Running Your Tests

## Prerequisites Check
Before running tests, verify:
- ✅ Xcode 15.0+ (for Swift Testing support)
- ✅ macOS 13.0+ deployment target
- ✅ Test target created and configured
- ✅ All test files added to test target

---

## Running Tests

### Option 1: Run All Tests
```bash
# In Terminal
xcodebuild test -scheme YourAppScheme -destination 'platform=macOS'

# Or press Cmd + U in Xcode
```

### Option 2: Run Specific Test Suite
```bash
# Click the ◆ icon next to @Suite in Xcode
# Or use Test Navigator (Cmd + 6)
```

### Option 3: Run Single Test
```bash
# Click the ◆ icon next to @Test in Xcode
# Or Ctrl+Opt+Cmd+U on the test function
```

---

## Expected Test Results

### Initial Run (Before Any Refactoring)

#### ✅ Should Pass (Ready to Run)
```
✓ KeyboardLayoutManagerTests/testTargetConfiguration
✓ LayoutAnalyticsTests/DurationCalculationTests/testSingleSessionDuration
✓ LayoutAnalyticsTests/DurationCalculationTests/testFormattedDurationHours
✓ LayoutAnalyticsTests/DurationCalculationTests/testFormattedDurationMinutes
✓ LayoutAnalyticsTests/DurationCalculationTests/testFormattedDurationSeconds
✓ LayoutAnalyticsTests/PercentageCalculationTests/testPercentageCalculation
✓ LayoutAnalyticsTests/PercentageCalculationTests/testZeroTotalDuration
✓ LayoutAnalyticsTests/AppStatisticsTests/testMostUsedLayout
✓ LayoutAnalyticsTests/AppStatisticsTests/testAppDurationFormatting
✓ LayoutAnalyticsTests/AppStatisticsTests/testShortAppDuration
✓ LayoutAnalyticsTests/AppStatisticsTests/testAppWithNoLayouts
✓ LayoutImageProtocolsTests/ImageCachingTests/testCacheAndRetrieve
✓ LayoutImageProtocolsTests/ImageCachingTests/testCacheMiss
✓ LayoutImageProtocolsTests/ImageCachingTests/testCacheOverwrite
✓ LayoutImageProtocolsTests/ImageCachingTests/testMultipleKeys
✓ LayoutImageProtocolsTests/ImageRenderingTests/testRenderCorrectSize
✓ LayoutImageProtocolsTests/ImageRenderingTests/testRenderWithoutCapsLock
✓ LayoutImageProtocolsTests/ImageRenderingTests/testRenderWithCapsLock
✓ LayoutImageProtocolsTests/ImageRenderingTests/testAsyncRendering
✓ LayoutImageProtocolsTests/ImageRenderingTests/testAsyncMatchesSync
✓ LayoutImageProtocolsTests/ImageRenderingTests/testRenderDifferentSizes
✓ LayoutImageProtocolsTests/ErrorHandlingTests/testErrorDescriptions
✓ LayoutImageProtocolsTests/ErrorHandlingTests/testLayoutNotFoundError
✓ LayoutImageProtocolsTests/ErrorHandlingTests/testImageNotFoundError
```

**Expected: 24 passing tests**

#### ⊘ Disabled Tests (Documented TODOs)
```
⊘ LayoutAnalyticsTests/SessionTrackingTests/testStartTracking (Disabled: Requires mock UserDefaults)
⊘ LayoutAnalyticsTests/SessionTrackingTests/testStopTracking (Disabled: Requires mock UserDefaults)
⊘ LayoutAnalyticsTests/SessionTrackingTests/testSwitchingLayouts (Disabled: Requires mock UserDefaults)
⊘ LayoutImageProtocolsTests/JSONLayoutMappingTests/testMissingJSONFile (Disabled: Requires custom test bundle)
⊘ LayoutImageProtocolsTests/JSONLayoutMappingTests/testCorruptedJSON (Disabled: Requires custom test bundle)
```

**Expected: 5 disabled tests (intentional)**

#### ⚠️ May Fail (Depends on Bundle Contents)
```
? LayoutImageProtocolsTests/JSONLayoutMappingTests/testLoadValidMapping
? LayoutImageProtocolsTests/JSONLayoutMappingTests/testUnknownLayoutThrowsError
```

**Note**: These tests depend on `Layout.json` being present in the test bundle. They may pass or fail depending on your bundle configuration.

---

## Interpreting Results

### Test Output in Xcode
```
Test Suite 'All tests' started
Test Suite 'LayoutAnalyticsTests' passed
  ✓ testSingleSessionDuration (0.001s)
  ✓ testFormattedDurationHours (0.001s)
  ...
Test Suite 'LayoutAnalyticsTests' passed (0.023s)

Test Suite 'All tests' passed
  Total: 24 tests, 24 passed, 0 failed
```

### Success Indicators
- ✅ Green checkmarks in Test Navigator
- ✅ "Test Succeeded" in console
- ✅ No red X marks in code editor

### Failure Investigation
If a test fails:
1. Read the failure message in the console
2. Check the `#expect()` statement that failed
3. Look at the values in the failure message
4. Use breakpoints to debug

---

## Next Steps After Initial Run

### Phase 1: Enable Session Tracking Tests
1. Refactor `LayoutAnalytics.swift`:
   ```swift
   final class LayoutAnalytics {
       private let defaults: UserDefaults
       
       static let shared = LayoutAnalytics()
       
       private init() {
           self.defaults = .standard
       }
       
       // Add this for testing
       init(defaults: UserDefaults) {
           self.defaults = defaults
       }
   }
   ```

2. Update test file to use mock:
   ```swift
   @Test("Start tracking creates new session")
   func testStartTracking() async throws {
       let mockDefaults = MockUserDefaults()
       let analytics = LayoutAnalytics(defaults: mockDefaults)
       
       analytics.startTracking(layout: "US", app: "Xcode")
       
       // Add assertions to verify state
   }
   ```

3. Remove `.disabled()` from tests and run again

### Phase 2: Add Test Bundle Resources
1. Create `TestResources` folder in test target
2. Add `TestLayout.json`:
   ```json
   {
     "U.S.": "flag_us",
     "French": "flag_fr",
     "German": "flag_de"
   }
   ```
3. Update tests to use test bundle
4. Enable JSON-related tests

### Phase 3: Expand Coverage
1. Create `SmartLayoutSuggestionsTests.swift`
2. Create `UserPreferencesTests.swift`
3. Create `LayoutGroupTests.swift`
4. Run tests after each addition

---

## Troubleshooting

### "Module 'KeyboardLayoutManager' not found"
**Solution**: 
- Check test target's build settings
- Ensure main app target allows testing: Build Settings → Enable Testability = Yes
- Clean build folder (Cmd + Shift + K) and rebuild

### "Use of unresolved identifier 'LayoutAnalytics'"
**Solution**:
- Verify `@testable import KeyboardLayoutManager` at top of test file
- Check that classes/structs are `public` or `internal` (not `private`)
- Rebuild project

### Tests fail with "Layout.json file not found"
**Solution**:
- This is expected - those specific tests need the JSON file in test bundle
- Either add the file to test bundle, or leave tests disabled for now
- The error handling tests verify that the error is thrown correctly

### Tests run but nothing appears in Test Navigator
**Solution**:
- Close and reopen Test Navigator (Cmd + 6)
- Clean build folder and rebuild
- Check that test target is selected in scheme

---

## Continuous Testing Workflow

### Before Every Commit
```bash
# Run tests
xcodebuild test -scheme YourAppScheme

# Check coverage (optional)
xcodebuild test -scheme YourAppScheme -enableCodeCoverage YES
```

### During Development
1. Write code
2. Write/update test
3. Run test (Cmd + U)
4. Refactor if needed
5. Run all tests before commit

### Test-Driven Development (TDD)
1. Write failing test first
2. Write minimum code to pass
3. Refactor code
4. Repeat

---

## Performance Expectations

### Test Speed
Most tests should be **very fast**:
- Duration calculation: < 0.001s
- Image caching: < 0.005s
- Rendering tests: < 0.010s
- Full suite: < 1 second

If tests are slow:
- Check for unexpected I/O operations
- Ensure mocks are being used
- Look for synchronous waits or delays

### Memory Usage
Tests should be memory-efficient:
- Use `@Suite` to organize tests
- Don't retain large objects between tests
- Clear caches in test cleanup if needed

---

## Code Coverage Goals

### Target Coverage
- **Overall**: 80%+
- **Business Logic**: 90%+
- **UI/Animation**: 50%+

### Viewing Coverage in Xcode
1. Enable code coverage: Scheme → Test → Options → Code Coverage
2. Run tests (Cmd + U)
3. View Report Navigator (Cmd + 9)
4. Select latest test run
5. Click Coverage tab

### What Coverage Numbers Mean
- **80%+**: Good coverage, most code paths tested
- **60-80%**: Acceptable, but could be better
- **<60%**: Needs more tests

---

## Getting Help

### If Tests Aren't Running
1. Check Xcode console for build errors
2. Verify test target configuration
3. Ensure Swift Testing is available (Xcode 15+)
4. Try creating a new simple test to isolate issue

### If You're Stuck
1. Review `TESTING_PLAN.md` for guidance
2. Check `TestUtilities.swift` for helper functions
3. Look at existing tests as examples
4. Consider what behavior you want to verify

---

## Success Checklist

After setup, you should have:
- ✅ Test target compiles successfully
- ✅ At least 20+ tests passing
- ✅ Test Navigator shows all test suites
- ✅ Can run individual tests
- ✅ Can run full test suite
- ✅ Understand how to add new tests

**You're ready to start comprehensive testing! 🎉**
