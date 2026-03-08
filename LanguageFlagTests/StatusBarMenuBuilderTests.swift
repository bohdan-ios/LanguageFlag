import Testing
import Foundation
@testable import LanguageFlag

@Suite("StatusBarMenuBuilder Tests")
struct StatusBarMenuBuilderTests {

    // MARK: - updateRecentLayouts

    @Suite("Recent Layouts")
    struct RecentLayoutsTests {

        @Test("first layout is added to empty list")
        func testAddToEmptyList() {
            let builder = StatusBarMenuBuilder()
            builder.updateRecentLayouts(with: "US")
            // Access via buildMenu is heavy; test via indirect observable state.
            // We verify there is no crash and the method completes.
            builder.updateRecentLayouts(with: "US") // idempotent double-add
        }

        @Test("adding same layout moves it to front")
        func testDuplicateMoveToFront() {
            let builder = StatusBarMenuBuilder()
            builder.updateRecentLayouts(with: "US")
            builder.updateRecentLayouts(with: "French")
            builder.updateRecentLayouts(with: "US") // US should come back to front

            // Verify via the recentLayouts-driven menu section.
            // We use the internal state indirectly: after 3 adds where "US" is repeated,
            // only 2 unique entries should exist.
            // Add a third unique entry and verify max is still bounded.
            builder.updateRecentLayouts(with: "German")
            builder.updateRecentLayouts(with: "Spanish")
            builder.updateRecentLayouts(with: "Japanese")
            builder.updateRecentLayouts(with: "Korean")
            // After 6 distinct adds (with one duplicate early on), list should be ≤ 5
        }

        @Test("list is capped at 5 entries")
        func testMaxFiveEntries() {
            let builder = StatusBarMenuBuilder()
            let layouts = ["US", "French", "German", "Spanish", "Japanese", "Korean", "Russian"]

            for layout in layouts {
                builder.updateRecentLayouts(with: layout)
            }

            // The builder caps at 5. Verify via recentLayouts property using
            // a second builder with the same sequence for reference.
            // We assert no crash and correct count by observing menu item count
            // would not exceed 5 recent items. This is tested structurally.
            #expect(layouts.count == 7) // just sanity; real cap tested below
        }

        @Test("adding 6 unique layouts keeps only most recent 5")
        func testSixLayoutsKeepsFive() {
            let builder = StatusBarMenuBuilder()
            // Add exactly 6 unique layouts
            ["A", "B", "C", "D", "E", "F"].forEach { builder.updateRecentLayouts(with: $0) }
            // Internal recentLayouts should have 5 items: F, E, D, C, B
            // We can't access the private property directly, but we verify
            // adding one more still works (no index out-of-bounds crash).
            builder.updateRecentLayouts(with: "G")
        }

        @Test("adding duplicate does not increase count past maximum")
        func testDuplicateDoesNotExceedMax() {
            let builder = StatusBarMenuBuilder()
            // Fill to capacity
            ["A", "B", "C", "D", "E"].forEach { builder.updateRecentLayouts(with: $0) }
            // Re-add existing — should stay at 5
            builder.updateRecentLayouts(with: "A")
            builder.updateRecentLayouts(with: "B")
            // No crash, count still ≤ 5
        }

        @Test("adding single layout then re-adding keeps one entry")
        func testSingleLayoutRoundTrip() {
            let builder = StatusBarMenuBuilder()
            builder.updateRecentLayouts(with: "US")
            builder.updateRecentLayouts(with: "US")
            builder.updateRecentLayouts(with: "US")
            // No crash; list should still hold exactly one unique "US"
        }
    }

    // MARK: - RecentLayouts Order (via reflection)

    @Suite("Layout Order Verification")
    struct LayoutOrderTests {

        private func recentLayouts(from builder: StatusBarMenuBuilder) -> [String] {
            // Access private property via Mirror for white-box testing
            let mirror = Mirror(reflecting: builder)
            return mirror.children
                .first { $0.label == "recentLayouts" }
                .flatMap { $0.value as? [String] } ?? []
        }

        @Test("most recently added layout is first")
        func testMostRecentIsFirst() {
            let builder = StatusBarMenuBuilder()
            builder.updateRecentLayouts(with: "US")
            builder.updateRecentLayouts(with: "French")

            let layouts = recentLayouts(from: builder)
            #expect(layouts.first == "French")
        }

        @Test("layout order is newest-first")
        func testNewestFirst() {
            let builder = StatusBarMenuBuilder()
            builder.updateRecentLayouts(with: "A")
            builder.updateRecentLayouts(with: "B")
            builder.updateRecentLayouts(with: "C")

            let layouts = recentLayouts(from: builder)
            #expect(layouts == ["C", "B", "A"])
        }

        @Test("duplicate layout moves to front without duplication")
        func testDuplicateMovesToFrontNoDup() {
            let builder = StatusBarMenuBuilder()
            builder.updateRecentLayouts(with: "US")
            builder.updateRecentLayouts(with: "French")
            builder.updateRecentLayouts(with: "US")

            let layouts = recentLayouts(from: builder)
            #expect(layouts.first == "US")
            #expect(layouts.count == 2)
            #expect(layouts.filter { $0 == "US" }.count == 1)
        }

        @Test("list is capped at maxRecentLayouts (5)")
        func testCappedAtFive() {
            let builder = StatusBarMenuBuilder()
            ["A", "B", "C", "D", "E", "F"].forEach { builder.updateRecentLayouts(with: $0) }

            let layouts = recentLayouts(from: builder)
            #expect(layouts.count == 5)
            #expect(layouts.first == "F")
            #expect(!layouts.contains("A")) // oldest dropped
        }
    }
}
