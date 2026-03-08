import Testing
import Foundation
@testable import LanguageFlag

@Suite("WindowAnimationFactory Tests")
struct WindowAnimationFactoryTests {

    // MARK: - All Styles Produce an Animation

    @Test("Every AnimationStyle produces a non-nil animation")
    func testAllStylesProduceAnimation() {
        for style in AnimationStyle.allCases {
            let animation = WindowAnimationFactory.animation(for: style)
            // If we reach this line, the factory returned without crashing
            _ = animation
        }
        #expect(AnimationStyle.allCases.count == 16)
    }

    // MARK: - Correct Concrete Types

    @Test("fade produces FadeAnimation")
    func testFadeAnimation() {
        #expect(WindowAnimationFactory.animation(for: .fade) is FadeAnimation)
    }

    @Test("slide produces SlideAnimation")
    func testSlideAnimation() {
        #expect(WindowAnimationFactory.animation(for: .slide) is SlideAnimation)
    }

    @Test("scale produces ScaleAnimation")
    func testScaleAnimation() {
        #expect(WindowAnimationFactory.animation(for: .scale) is ScaleAnimation)
    }

    @Test("pixelate produces PixelateAnimation")
    func testPixelateAnimation() {
        #expect(WindowAnimationFactory.animation(for: .pixelate) is PixelateAnimation)
    }

    @Test("blur produces BlurAnimation")
    func testBlurAnimation() {
        #expect(WindowAnimationFactory.animation(for: .blur) is BlurAnimation)
    }

    @Test("hologram produces HologramAnimation")
    func testHologramAnimation() {
        #expect(WindowAnimationFactory.animation(for: .hologram) is HologramAnimation)
    }

    @Test("energyPortal produces EnergyPortalAnimation")
    func testEnergyPortalAnimation() {
        #expect(WindowAnimationFactory.animation(for: .energyPortal) is EnergyPortalAnimation)
    }

    @Test("digitalMaterialize produces DigitalMaterializeAnimation")
    func testDigitalMaterializeAnimation() {
        #expect(WindowAnimationFactory.animation(for: .digitalMaterialize) is DigitalMaterializeAnimation)
    }

    @Test("liquidRipple produces LiquidRippleAnimation")
    func testLiquidRippleAnimation() {
        #expect(WindowAnimationFactory.animation(for: .liquidRipple) is LiquidRippleAnimation)
    }

    @Test("inkDiffusion produces InkDiffusionAnimation")
    func testInkDiffusionAnimation() {
        #expect(WindowAnimationFactory.animation(for: .inkDiffusion) is InkDiffusionAnimation)
    }

    @Test("vhsGlitch produces VHSGlitchAnimation")
    func testVHSGlitchAnimation() {
        #expect(WindowAnimationFactory.animation(for: .vhsGlitch) is VHSGlitchAnimation)
    }

    @Test("flip produces FlipAnimation")
    func testFlipAnimation() {
        #expect(WindowAnimationFactory.animation(for: .flip) is FlipAnimation)
    }

    @Test("bounce produces BounceAnimation")
    func testBounceAnimation() {
        #expect(WindowAnimationFactory.animation(for: .bounce) is BounceAnimation)
    }

    @Test("rotate produces RotateAnimation")
    func testRotateAnimation() {
        #expect(WindowAnimationFactory.animation(for: .rotate) is RotateAnimation)
    }

    @Test("swing produces SwingAnimation")
    func testSwingAnimation() {
        #expect(WindowAnimationFactory.animation(for: .swing) is SwingAnimation)
    }

    @Test("elastic produces ElasticAnimation")
    func testElasticAnimation() {
        #expect(WindowAnimationFactory.animation(for: .elastic) is ElasticAnimation)
    }

    // MARK: - Each Style Returns a Distinct Type

    @Test("basic animation styles return distinct types")
    func testBasicStylesDistinct() {
        let fade = WindowAnimationFactory.animation(for: .fade)
        let slide = WindowAnimationFactory.animation(for: .slide)
        let scale = WindowAnimationFactory.animation(for: .scale)

        #expect(!(fade is SlideAnimation))
        #expect(!(slide is FadeAnimation))
        #expect(!(scale is FadeAnimation))
    }

    @Test("factory creates new instances each call")
    func testFactoryCreatesNewInstances() {
        let a1 = WindowAnimationFactory.animation(for: .fade) as AnyObject
        let a2 = WindowAnimationFactory.animation(for: .fade) as AnyObject
        #expect(a1 !== a2)
    }
}
