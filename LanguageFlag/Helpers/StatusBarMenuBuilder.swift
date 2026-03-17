import Cocoa
import LaunchAtLogin
import Carbon

final class StatusBarMenuBuilder {

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
        let currentLayout = TISCopyCurrentKeyboardInputSource().takeRetainedValue().name
        let currentItem = menu.addItem(withTitle: "Current: \(currentLayout)", action: nil, keyEquivalent: "")
        currentItem.isEnabled = false

        menu.addItem(NSMenuItem.separator())

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
        let availableLayouts = getAvailableLayouts()

        for layout in availableLayouts {
            let item = menu.addItem(withTitle: layout, action: #selector(StatusBarManager.switchToLayout(_:)), keyEquivalent: "")
            item.representedObject = layout
            item.target = target
            item.state = layout == currentLayout ? .on : .off
        }

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

    private func getAvailableLayouts() -> [String] {
        let inputSources = TISCreateInputSourceList(nil, false).takeRetainedValue() as? [TISInputSource] ?? []
        return inputSources.compactMap { $0.name }.sorted()
    }
}
