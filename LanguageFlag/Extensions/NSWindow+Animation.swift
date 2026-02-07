import Cocoa

enum SlideDirection {

    case up, down, left, right
}

protocol Animatable {

    func fadeIn(duration: TimeInterval, completion: (() -> Void)?)
    func fadeOut(duration: TimeInterval, completion: (() -> Void)?)
    func slideIn(duration: TimeInterval, direction: SlideDirection, maxDistance: CGFloat?, completion: (() -> Void)?)
    func slideOut(duration: TimeInterval, direction: SlideDirection, maxDistance: CGFloat?, completion: (() -> Void)?)
    func scaleIn(duration: TimeInterval, completion: (() -> Void)?)
    func scaleOut(duration: TimeInterval, completion: (() -> Void)?)
    func pixelateIn(duration: TimeInterval, completion: (() -> Void)?)
    func pixelateOut(duration: TimeInterval, completion: (() -> Void)?)
    func blurIn(duration: TimeInterval, completion: (() -> Void)?)
    func blurOut(duration: TimeInterval, completion: (() -> Void)?)
    func flipIn(duration: TimeInterval, completion: (() -> Void)?)
    func flipOut(duration: TimeInterval, completion: (() -> Void)?)
    func bounceIn(duration: TimeInterval, completion: (() -> Void)?)
    func bounceOut(duration: TimeInterval, completion: (() -> Void)?)
    func hologramIn(duration: TimeInterval, completion: (() -> Void)?)
    func hologramOut(duration: TimeInterval, completion: (() -> Void)?)
    func energyPortalIn(duration: TimeInterval, completion: (() -> Void)?)
    func energyPortalOut(duration: TimeInterval, completion: (() -> Void)?)
    func digitalMaterializeIn(duration: TimeInterval, completion: (() -> Void)?)
    func digitalMaterializeOut(duration: TimeInterval, completion: (() -> Void)?)
    func liquidRippleIn(duration: TimeInterval, completion: (() -> Void)?)
    func liquidRippleOut(duration: TimeInterval, completion: (() -> Void)?)
    func inkDiffusionIn(duration: TimeInterval, completion: (() -> Void)?)
    func inkDiffusionOut(duration: TimeInterval, completion: (() -> Void)?)
    func vhsGlitchIn(duration: TimeInterval, completion: (() -> Void)?)
    func vhsGlitchOut(duration: TimeInterval, completion: (() -> Void)?)
    func rotateIn(duration: TimeInterval, completion: (() -> Void)?)
    func rotateOut(duration: TimeInterval, completion: (() -> Void)?)
    func swingIn(duration: TimeInterval, completion: (() -> Void)?)
    func swingOut(duration: TimeInterval, completion: (() -> Void)?)
    func elasticIn(duration: TimeInterval, completion: (() -> Void)?)
    func elasticOut(duration: TimeInterval, completion: (() -> Void)?)
}

extension NSWindow: Animatable {
    
    // MARK: - Basic Animations
    
    func fadeIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .fade).animateIn(window: self, duration: duration, completion: completion)
    }

    func fadeOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .fade).animateOut(window: self, duration: duration, completion: completion)
    }

    func slideIn(duration: TimeInterval, direction: SlideDirection = .up, maxDistance: CGFloat? = nil, completion: (() -> Void)? = nil) {
        let anim = SlideAnimation()
        anim.forcedDirection = direction
        anim.forcedMaxDistance = maxDistance
        anim.animateIn(window: self, duration: duration, completion: completion)
    }

    func slideOut(duration: TimeInterval, direction: SlideDirection = .down, maxDistance: CGFloat? = nil, completion: (() -> Void)? = nil) {
        let anim = SlideAnimation()
        anim.forcedDirection = direction
        anim.forcedMaxDistance = maxDistance
        anim.animateOut(window: self, duration: duration, completion: completion)
    }

    func scaleIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .scale).animateIn(window: self, duration: duration, completion: completion)
    }

    func scaleOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .scale).animateOut(window: self, duration: duration, completion: completion)
    }
    
    // MARK: - Filter-Based Animations
    
    func pixelateIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .pixelate).animateIn(window: self, duration: duration, completion: completion)
    }

    func pixelateOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .pixelate).animateOut(window: self, duration: duration, completion: completion)
    }

    func blurIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .blur).animateIn(window: self, duration: duration, completion: completion)
    }

    func blurOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .blur).animateOut(window: self, duration: duration, completion: completion)
    }
    
    func hologramIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .hologram).animateIn(window: self, duration: duration, completion: completion)
    }
    
    func hologramOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .hologram).animateOut(window: self, duration: duration, completion: completion)
    }
    
    func energyPortalIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .energyPortal).animateIn(window: self, duration: duration, completion: completion)
    }
    
    func energyPortalOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .energyPortal).animateOut(window: self, duration: duration, completion: completion)
    }
    
    func digitalMaterializeIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .digitalMaterialize).animateIn(window: self, duration: duration, completion: completion)
    }
    
    func digitalMaterializeOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .digitalMaterialize).animateOut(window: self, duration: duration, completion: completion)
    }
    
    func liquidRippleIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .liquidRipple).animateIn(window: self, duration: duration, completion: completion)
    }
    
    func liquidRippleOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .liquidRipple).animateOut(window: self, duration: duration, completion: completion)
    }
    
    func inkDiffusionIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .inkDiffusion).animateIn(window: self, duration: duration, completion: completion)
    }
    
    func inkDiffusionOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .inkDiffusion).animateOut(window: self, duration: duration, completion: completion)
    }
    
    func vhsGlitchIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .vhsGlitch).animateIn(window: self, duration: duration, completion: completion)
    }
    
    func vhsGlitchOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .vhsGlitch).animateOut(window: self, duration: duration, completion: completion)
    }
    
    // MARK: - Transform Animations

    func flipIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .flip).animateIn(window: self, duration: duration, completion: completion)
    }

    func flipOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .flip).animateOut(window: self, duration: duration, completion: completion)
    }

    func bounceIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .bounce).animateIn(window: self, duration: duration, completion: completion)
    }

    func bounceOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .bounce).animateOut(window: self, duration: duration, completion: completion)
    }
    
    func rotateIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .rotate).animateIn(window: self, duration: duration, completion: completion)
    }
    
    func rotateOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .rotate).animateOut(window: self, duration: duration, completion: completion)
    }
    
    func swingIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .swing).animateIn(window: self, duration: duration, completion: completion)
    }
    
    func swingOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .swing).animateOut(window: self, duration: duration, completion: completion)
    }
    
    func elasticIn(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .elastic).animateIn(window: self, duration: duration, completion: completion)
    }
    
    func elasticOut(duration: TimeInterval, completion: (() -> Void)? = nil) {
        WindowAnimationFactory.animation(for: .elastic).animateOut(window: self, duration: duration, completion: completion)
    }
}
