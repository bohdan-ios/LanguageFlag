import Foundation

/// Centralized feature flag definitions.
/// Flags are resolved at compile time via SWIFT_ACTIVE_COMPILATION_CONDITIONS.
/// - Debug & QAT: all features ON
/// - Production: features selectively disabled
enum FeatureFlags {

    static var isShortcutsEnabled: Bool {
        #if FEATURE_SHORTCUTS
        return true
        #else
        return false
        #endif
    }

    static var isAnalyticsEnabled: Bool {
        #if FEATURE_ANALYTICS
        return true
        #else
        return false
        #endif
    }

    static var isGroupsEnabled: Bool {
        #if FEATURE_GROUPS
        return true
        #else
        return false
        #endif
    }
}
