import Cocoa
import LaunchAtLogin
import Carbon

final class StatusBarMenuBuilder {

    private var recentLayouts: [String] = []
    private let maxRecentLayouts = 5

    // swiftlint:disable function_body_length
    /// Builds the menu for the status bar.
    /// - Parameters:
    ///   - launchAtLoginAction: Selector for toggling Launch at Login.
    ///   - preferencesAction: Selector for opening preferences.
    ///   - exitAction: Selector for exiting the app.
    ///   - target: The target for menu actions.
    /// - Returns: A configured `NSMenu` instance.
    func buildMenu(
        launchAtLoginAction: Selector,
        preferencesAction: Selector,
        exitAction: Selector,
        target: AnyObject
    ) -> NSMenu {
        let menu = NSMenu()

        // Current Layout Info
        let currentLayout = TISCopyCurrentKeyboardInputSource().takeUnretainedValue().name
        let currentItem = menu.addItem(withTitle: "Current: \(currentLayout)", action: nil, keyEquivalent: "")
        currentItem.isEnabled = false

        menu.addItem(NSMenuItem.separator())

        // Recent Layouts
        if !recentLayouts.isEmpty {
            let recentMenuItem = menu.addItem(withTitle: "Recent Layouts", action: nil, keyEquivalent: "")
            recentMenuItem.isEnabled = false

            for layout in recentLayouts {
                let item = menu.addItem(withTitle: "  \(layout)", action: #selector(StatusBarManager.switchToLayout(_:)), keyEquivalent: "")
                item.representedObject = layout
                item.target = target
            }

            menu.addItem(NSMenuItem.separator())
        }

        // Layout Groups
        #if FEATURE_GROUPS
        let groups = LayoutGroupManager.shared.getGroups()
        if !groups.isEmpty {
            let groupsMenu = NSMenu()

            for group in groups {
                let groupItem = NSMenuItem(title: group.name, action: #selector(StatusBarManager.activateGroup(_:)), keyEquivalent: "")
                groupItem.representedObject = group
                groupItem.target = target
                groupsMenu.addItem(groupItem)
            }

            let groupsMenuItem = menu.addItem(withTitle: "Layout Groups", action: nil, keyEquivalent: "")
            menu.setSubmenu(groupsMenu, for: groupsMenuItem)

            menu.addItem(NSMenuItem.separator())
        }
        #endif

        // All Available Layouts
        let layoutsMenu = NSMenu()
        let availableLayouts = getAvailableLayouts()

        for layout in availableLayouts {
            let item = NSMenuItem(title: layout, action: #selector(StatusBarManager.switchToLayout(_:)), keyEquivalent: "")
            item.representedObject = layout
            item.target = target
            item.state = layout == currentLayout ? .on : .off
            layoutsMenu.addItem(item)
        }

        let layoutsMenuItem = menu.addItem(withTitle: "All Layouts", action: nil, keyEquivalent: "")
        menu.setSubmenu(layoutsMenu, for: layoutsMenuItem)

        menu.addItem(NSMenuItem.separator())

        // Launch at Login
        let launchItem = menu.addItem(
            withTitle: "Launch at login",
            action: launchAtLoginAction,
            keyEquivalent: ""
        )
        launchItem.state = LaunchAtLogin.isEnabled ? .on : .off
        launchItem.target = target

        menu.addItem(NSMenuItem.separator())

        // Preferences
        let prefsItem = menu.addItem(
            withTitle: "Preferences...",
            action: preferencesAction,
            keyEquivalent: ","
        )
        prefsItem.target = target

        menu.addItem(NSMenuItem.separator())

        // Exit
        let exitItem = menu.addItem(withTitle: "Exit", action: exitAction, keyEquivalent: "")
        exitItem.target = target

        return menu
    }
    // swiftlint:enable function_body_length

    func updateRecentLayouts(with layout: String) {
        // Remove if already exists
        recentLayouts.removeAll { $0 == layout }

        // Add to front
        recentLayouts.insert(layout, at: 0)

        // Keep only max recent
        if recentLayouts.count > maxRecentLayouts {
            recentLayouts = Array(recentLayouts.prefix(maxRecentLayouts))
        }
    }

    private func getAvailableLayouts() -> [String] {
        // swiftlint:disable:next force_cast
        let inputSources = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]
        return inputSources.compactMap { $0.name }.sorted()
    }
}
