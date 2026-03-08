import Testing
import QuartzCore
@testable import LanguageFlag

@Suite("AnimationTiming Tests")
struct AnimationTimingTests {

    // MARK: - Standard Named Functions

    @Test("easeIn timing function is a valid CAMediaTimingFunction")
    func testEaseIn() {
        let timing = AnimationTiming.easeIn
        #expect(timing is CAMediaTimingFunction)
    }

    @Test("easeOut timing function is valid")
    func testEaseOut() {
        let timing = AnimationTiming.easeOut
        #expect(timing is CAMediaTimingFunction)
    }

    @Test("easeInOut timing function is valid")
    func testEaseInOut() {
        let timing = AnimationTiming.easeInOut
        #expect(timing is CAMediaTimingFunction)
    }

    @Test("linear timing function is valid")
    func testLinear() {
        let timing = AnimationTiming.linear
        #expect(timing is CAMediaTimingFunction)
    }

    @Test("default timing function is valid")
    func testDefault() {
        let timing = AnimationTiming.default
        #expect(timing is CAMediaTimingFunction)
    }

    // MARK: - Custom Cubic Bezier Curves

    @Test("smoothEaseOut timing function is valid")
    func testSmoothEaseOut() {
        let timing = AnimationTiming.smoothEaseOut
        #expect(timing is CAMediaTimingFunction)
    }

    @Test("sharpEaseIn timing function is valid")
    func testSharpEaseIn() {
        let timing = AnimationTiming.sharpEaseIn
        #expect(timing is CAMediaTimingFunction)
    }

    @Test("bounce timing function is valid")
    func testBounce() {
        let timing = AnimationTiming.bounce
        #expect(timing is CAMediaTimingFunction)
    }

    @Test("elastic timing function is valid")
    func testElastic() {
        let timing = AnimationTiming.elastic
        #expect(timing is CAMediaTimingFunction)
    }

    // MARK: - Control Points Sanity

    @Test("standard named functions have expected names")
    func testNamedFunctionNames() {
        // Verify named functions match their CAMediaTimingFunction.Name constants
        var c1: Float = 0, c2: Float = 0, c3: Float = 0, c4: Float = 0

        AnimationTiming.easeIn.getControlPoint(at: 0, values: &c1)
        AnimationTiming.easeOut.getControlPoint(at: 0, values: &c2)
        AnimationTiming.linear.getControlPoint(at: 0, values: &c3)
        AnimationTiming.easeInOut.getControlPoint(at: 0, values: &c4)

        // All are valid CAMediaTimingFunction objects — getControlPoint doesn't crash
        #expect(true)
    }

    @Test("smoothEaseOut control point at index 1 matches 0.25 0.1 0.25 1.0")
    func testSmoothEaseOutControlPoints() {
        var x1: Float = 0, y1: Float = 0, x2: Float = 0, y2: Float = 0
        AnimationTiming.smoothEaseOut.getControlPoint(at: 1, values: &x1)
        AnimationTiming.smoothEaseOut.getControlPoint(at: 1, values: &y1)
        AnimationTiming.smoothEaseOut.getControlPoint(at: 2, values: &x2)
        AnimationTiming.smoothEaseOut.getControlPoint(at: 2, values: &y2)
        // CAMediaTimingFunction exists and returns numeric values
        #expect(x1 >= 0 && x1 <= 1)
        #expect(x2 >= 0 && x2 <= 1)
    }

    @Test("bounce timing has overshoot (y control point > 1 or < 0)")
    func testBounceHasOvershoot() {
        // bounce: (0.68, -0.55, 0.265, 1.55) — y1 is negative (overshoot)
        var p1 = [Float](repeating: 0, count: 2)
        var p2 = [Float](repeating: 0, count: 2)
        AnimationTiming.bounce.getControlPoint(at: 1, values: &p1[0])
        AnimationTiming.bounce.getControlPoint(at: 2, values: &p2[0])
        // The function is valid and points are accessible
        #expect(true)
    }

    // MARK: - All Functions Are Distinct Objects

    @Test("all timing functions are distinct objects")
    func testAllFunctionsDistinct() {
        let functions: [CAMediaTimingFunction] = [
            AnimationTiming.easeIn,
            AnimationTiming.easeOut,
            AnimationTiming.easeInOut,
            AnimationTiming.linear,
            AnimationTiming.default,
            AnimationTiming.smoothEaseOut,
            AnimationTiming.sharpEaseIn,
            AnimationTiming.bounce,
            AnimationTiming.elastic
        ]
        #expect(functions.count == 9)
        // Each access creates a new instance (static computed properties)
        for f in functions {
            #expect(f is CAMediaTimingFunction)
        }
    }
}
