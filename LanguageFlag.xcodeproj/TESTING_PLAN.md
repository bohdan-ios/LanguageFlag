# Keyboard Layout Manager - Testing Plan

## Overview
This document outlines the comprehensive testing strategy for the Keyboard Layout Manager macOS application, prioritizing tests from most critical to nice-to-have.

## Test Target Structure
- **Target Name**: KeyboardLayoutManagerTests
- **Framework**: Swift Testing (macOS 13.0+)
- **Test Organization**: Organized by module/component

---

## Priority 1: Core Business Logic Tests (Start Here)

### 1.1 Layout Analytics Tests (`LayoutAnalyticsTests.swift`)
**Why First**: Core feature that tracks usage, must be reliable and accurate.

- **Statistics Calculation**
  - [ ] Test duration calculation for single session
  - [ ] Test duration aggregation across multiple sessions
  - [ ] Test percentage calculation with multiple layouts
  - [ ] Test formatted duration strings (hours, minutes, seconds)
  - [ ] Test statistics sorting by duration

- **Session Tracking**
  - [ ] Test starting a new tracking session
  - [ ] Test ending current session properly
  - [ ] Test switching between layouts (ending old, starting new)
  - [ ] Test tracking with nil app name
  - [ ] Test tracking when analytics is disabled

- **Data Persistence**
  - [ ] Test saving usage records to UserDefaults
  - [ ] Test loading usage records from UserDefaults
  - [ ] Test clearing all data
  - [ ] Test handling corrupted data

- **App Statistics**
  - [ ] Test app-level statistics aggregation
  - [ ] Test most-used layout per app
  - [ ] Test app statistics sorting

### 1.2 Smart Layout Suggestions Tests (`SmartLayoutSuggestionsTests.swift`)
**Why Second**: User-facing feature that impacts UX significantly.

- **Suggestion Logic**
  - [ ] Test basic app-layout association
  - [ ] Test suggestion confidence scoring
  - [ ] Test minimum usage threshold
  - [ ] Test top suggestion selection
  - [ ] Test handling apps with no history

- **Learning and Adaptation**
  - [ ] Test recording new usage patterns
  - [ ] Test updating existing patterns
  - [ ] Test pattern decay over time (if implemented)

### 1.3 Layout Image Protocols Tests (`LayoutImageProtocolsTests.swift`)
**Why Third**: Core infrastructure for displaying layouts correctly.

- **JSON Layout Mapping**
  - [ ] Test loading valid Layout.json
  - [ ] Test handling missing Layout.json file
  - [ ] Test handling corrupted JSON
  - [ ] Test retrieving image name for known layout
  - [ ] Test error handling for unknown layout

- **Image Caching**
  - [ ] Test caching an image
  - [ ] Test retrieving cached image
  - [ ] Test cache miss returns nil
  - [ ] Test cache memory management (eviction)

- **Image Rendering**
  - [ ] Test basic image rendering with correct size
  - [ ] Test rendering with Caps Lock indicator
  - [ ] Test rendering without Caps Lock indicator
  - [ ] Test async rendering completion
  - [ ] Test Caps Lock indicator positioning and styling

---

## Priority 2: Data Model & Business Rules

### 2.1 User Preferences Tests (`UserPreferencesTests.swift`)
- [ ] Test default values initialization
- [ ] Test reading and writing preferences
- [ ] Test preference change notifications
- [ ] Test preference persistence across app launches
- [ ] Test showInMenuBar toggle behavior

### 2.2 Layout Group Tests (`LayoutGroupTests.swift`)
- [ ] Test creating a layout group
- [ ] Test adding layouts to a group
- [ ] Test removing layouts from a group
- [ ] Test group activation logic
- [ ] Test persistence of groups
- [ ] Test handling empty groups

### 2.3 Keyboard Layout Notification Tests (`KeyboardLayoutNotificationTests.swift`)
- [ ] Test model creation with all properties
- [ ] Test Caps Lock state changes
- [ ] Test equality and hashing (if applicable)

---

## Priority 3: UI Components & Integration

### 3.1 Layout Image Container Tests (`LayoutImageContainerTests.swift`)
- [ ] Test singleton initialization
- [ ] Test flag image retrieval with valid layout
- [ ] Test fallback behavior for missing images
- [ ] Test cache integration
- [ ] Test concurrent access (thread safety)

### 3.2 Status Bar Menu Builder Tests (`StatusBarMenuBuilderTests.swift`)
- [ ] Test building complete menu structure
- [ ] Test recent layouts section
- [ ] Test groups section (if FEATURE_GROUPS enabled)
- [ ] Test menu item actions are connected
- [ ] Test Launch at Login state display
- [ ] Test menu updates on layout change

---

## Priority 4: Animation & Visual Effects

### 4.1 Digital Materialize Animation Tests (`DigitalMaterializeAnimationTests.swift`)
- [ ] Test animate-in creates proper filters
- [ ] Test animate-out creates proper filters
- [ ] Test animation completion callbacks
- [ ] Test animation duration
- [ ] Test cleanup after animation
- [ ] Test layer masking setup

---

## Priority 5: Integration & System Tests

### 5.1 Status Bar Manager Integration Tests (`StatusBarManagerIntegrationTests.swift`)
- [ ] Test initialization with dependencies
- [ ] Test keyboard layout change notification handling
- [ ] Test Caps Lock change notification handling
- [ ] Test menu rebuilding on open
- [ ] Test icon updates on preference changes
- [ ] Test switching to layout via menu

### 5.2 Analytics Integration Tests
- [ ] Test analytics initialization on app launch
- [ ] Test analytics tracking across layout switches
- [ ] Test analytics disabled state
- [ ] Test analytics with smart suggestions integration

---

## Test Utilities & Mocks

### Mock Objects to Create
1. **MockLayoutMappingProvider** - Returns predictable layout mappings
2. **MockImageCache** - Controlled cache for testing
3. **MockImageRenderer** - Fast, deterministic rendering
4. **MockUserDefaults** - Isolated storage for tests
5. **MockNotificationCenter** - Track and verify notifications

### Test Data Files
- `TestLayout.json` - Valid layout mapping for tests
- Sample flag images for testing image rendering

---

## Testing Best Practices

### Setup
- Use `@Test` attribute for individual tests
- Use `@Suite` to organize related tests
- Create helper functions for common setup

### Isolation
- Each test should be independent
- Use dependency injection to provide mocks
- Reset state between tests

### Assertions
- Use `#expect()` for standard assertions
- Use `#require()` for optional unwrapping
- Provide descriptive messages

### Async Testing
- Use `async throws` for async tests
- Test both success and failure paths
- Test timeout scenarios

---

## Immediate Action Items

### Week 1: Foundation
1. ✅ Create test target
2. Create mock objects and test utilities
3. Implement LayoutAnalyticsTests (Priority 1.1)
4. Implement LayoutImageProtocolsTests (Priority 1.3)

### Week 2: Core Features  
5. Implement SmartLayoutSuggestionsTests (Priority 1.2)
6. Implement UserPreferencesTests (Priority 2.1)
7. Implement LayoutGroupTests (Priority 2.2)

### Week 3: Integration
8. Implement LayoutImageContainerTests (Priority 3.1)
9. Implement StatusBarManagerIntegrationTests (Priority 5.1)
10. Review and refine test coverage

---

## Code Coverage Goals
- **Target**: 80% code coverage minimum
- **Priority**: 100% coverage for business logic (analytics, suggestions)
- **Acceptable Lower Coverage**: Animation and UI presentation code

---

## CI/CD Integration
- Run tests on every commit
- Fail builds if critical tests fail
- Generate coverage reports
- Run performance tests weekly

---

## Notes
- Some tests may require macOS-specific entitlements
- System-level tests (TISInputSource) may need integration test approach
- Consider using XCTest for UI testing if needed alongside Swift Testing
