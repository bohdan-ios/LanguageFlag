// swiftlint:disable force_cast

import Foundation
import Carbon

struct LayoutGroup: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var layouts: [String]
    var color: String // Hex color for visual distinction

    init(id: UUID = UUID(), name: String, layouts: [String], color: String = "#007AFF") {
        self.id = id
        self.name = name
        self.layouts = layouts
        self.color = color
    }
}

final class LayoutGroupManager {

    static let shared = LayoutGroupManager()

    private let defaults = UserDefaults.standard
    private let groupsKey = "layoutGroups"
    private let activeGroupKey = "activeLayoutGroup"

    private init() {
        // Initialize with default groups if none exist
        if getGroups().isEmpty {
            createDefaultGroups()
        }
    }

    // MARK: - Public API

    func getGroups() -> [LayoutGroup] {
        guard
            let data = defaults.data(forKey: groupsKey),
            let groups = try? JSONDecoder().decode([LayoutGroup].self, from: data)
        else {
            return []
        }
        return groups
    }

    func saveGroup(_ group: LayoutGroup) {
        var groups = getGroups()

        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
        } else {
            groups.append(group)
        }

        saveGroups(groups)
    }

    func deleteGroup(_ group: LayoutGroup) {
        var groups = getGroups()
        groups.removeAll { $0.id == group.id }
        saveGroups(groups)

        // Clear active group if it was deleted
        if activeGroup?.id == group.id {
            activeGroup = nil
        }
    }

    var activeGroup: LayoutGroup? {
        get {
            guard
                let data = defaults.data(forKey: activeGroupKey),
                let group = try? JSONDecoder().decode(LayoutGroup.self, from: data)
            else {
                return nil
            }
            return group
        }
        set {
            if let newValue = newValue,
               let encoded = try? JSONEncoder().encode(newValue) {
                defaults.set(encoded, forKey: activeGroupKey)
                NotificationCenter.default.post(name: .layoutGroupChanged, object: newValue)
            } else {
                defaults.removeObject(forKey: activeGroupKey)
                NotificationCenter.default.post(name: .layoutGroupChanged, object: nil)
            }
        }
    }

    func getAvailableLayouts() -> [String] {
        let inputSources = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]
        return inputSources.compactMap { $0.name }
    }

    // MARK: - Private

    private func saveGroups(_ groups: [LayoutGroup]) {
        if let encoded = try? JSONEncoder().encode(groups) {
            defaults.set(encoded, forKey: groupsKey)
        }
    }

    private func createDefaultGroups() {
        let defaultGroups = [
            LayoutGroup(name: "Work", layouts: [], color: "#007AFF"),
            LayoutGroup(name: "Personal", layouts: [], color: "#34C759"),
            LayoutGroup(name: "Programming", layouts: [], color: "#FF9500")
        ]

        saveGroups(defaultGroups)
    }
}

// MARK: - Notification Names
extension Notification.Name {

    static let layoutGroupChanged = Notification.Name("layoutGroupChanged")
}
