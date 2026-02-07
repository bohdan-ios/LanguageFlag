import SwiftUI

/// Layout groups preferences pane for organizing layouts into groups
struct GroupsPreferencesPane: View {

    // MARK: - Variables
    @State private var groups: [LayoutGroup] = []
    @State private var activeGroup: LayoutGroup?
    @State private var showingAddGroup = false
    @State private var editingGroup: LayoutGroup?

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection

                Divider()
                
                if let active = activeGroup {
                    activeGroupSection(active)

                    Divider()
                }
                
                groupsListSection

                Spacer().frame(height: 20)
            }
            .padding()
        }
        .onAppear { refreshGroups() }
        .sheet(isPresented: $showingAddGroup) {
            LayoutGroupEditor(group: nil, onSave: { group in
                LayoutGroupManager.shared.saveGroup(group)
                showingAddGroup = false
                refreshGroups()
            })
        }
        .sheet(item: $editingGroup) { group in
            LayoutGroupEditor(group: group, onSave: { updatedGroup in
                LayoutGroupManager.shared.saveGroup(updatedGroup)
                editingGroup = nil
                refreshGroups()
            })
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Layout Groups")
                    .font(.headline)

                Spacer()

                Button {
                    showingAddGroup = true
                } label: {
                    Label("New Group", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }

            Text("Organize your keyboard layouts into groups for quick switching")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func activeGroupSection(_ active: LayoutGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Active Group")
                .font(.headline)

            HStack {
                Circle()
                    .fill(Color(hex: active.color))
                    .frame(width: 12, height: 12)

                Text(active.name)
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()

                Button("Deactivate") {
                    LayoutGroupManager.shared.activeGroup = nil
                    refreshGroups()
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: active.color).opacity(0.1))
            )
        }
    }
    
    private var groupsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Groups")
                .font(.headline)

            if groups.isEmpty {
                Text("No groups yet. Create your first group to organize layouts.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(groups) { group in
                        LayoutGroupRow(
                            group: group,
                            isActive: activeGroup?.id == group.id,
                            onActivate: {
                                LayoutGroupManager.shared.activeGroup = group
                                refreshGroups()
                            },
                            onEdit: { editingGroup = group },
                            onDelete: {
                                LayoutGroupManager.shared.deleteGroup(group)
                                refreshGroups()
                            }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Private
private extension GroupsPreferencesPane {
    
    func refreshGroups() {
        groups = LayoutGroupManager.shared.getGroups()
        activeGroup = LayoutGroupManager.shared.activeGroup
    }
}

// MARK: - Layout Group Row
struct LayoutGroupRow: View {

    // MARK: - Variables
    private let group: LayoutGroup
    private let isActive: Bool
    private let onActivate: () -> Void
    private let onEdit: () -> Void
    private let onDelete: () -> Void
    
    // MARK: - Init
    init(
        group: LayoutGroup,
        isActive: Bool,
        onActivate: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.group = group
        self.isActive = isActive
        self.onActivate = onActivate
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: group.color))
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text("\(group.layouts.count) layout\(group.layouts.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !isActive {
                Button("Activate") { onActivate() }
                    .buttonStyle(.borderless)
                    .foregroundColor(.accentColor)
            }

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

// MARK: - Layout Group Editor
struct LayoutGroupEditor: View {

    // MARK: - Variables
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var selectedLayouts: Set<String>
    @State private var selectedColor: String
    
    private let group: LayoutGroup?
    private let onSave: (LayoutGroup) -> Void
    private let availableLayouts: [String]
    private let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00"
    ]
    
    // MARK: - Init
    init(
        group: LayoutGroup?,
        onSave: @escaping (LayoutGroup) -> Void
    ) {
        self.group = group
        self.onSave = onSave
        self.availableLayouts = LayoutGroupManager.shared.getAvailableLayouts()
        _name = State(initialValue: group?.name ?? "")
        _selectedLayouts = State(initialValue: Set(group?.layouts ?? []))
        _selectedColor = State(initialValue: group?.color ?? "#007AFF")
    }

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        VStack(spacing: 20) {
            Text(group == nil ? "New Layout Group" : "Edit Layout Group")
                .font(.headline)

            nameSection

            colorSection

            layoutsSection

            buttonsSection
        }
        .padding(24)
        .frame(width: 400, height: 450)
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Group Name")
                .font(.caption)
                .foregroundColor(.secondary)

            TextField("e.g., Work, Personal", text: $name)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach(colorOptions, id: \.self) { color in
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                        )
                        .onTapGesture { selectedColor = color }
                }
            }
        }
    }
    
    private var layoutsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Layouts")
                .font(.caption)
                .foregroundColor(.secondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(availableLayouts, id: \.self) { layout in
                        Toggle(layout, isOn: Binding(
                            get: { selectedLayouts.contains(layout) },
                            set: { isOn in
                                if isOn {
                                    selectedLayouts.insert(layout)
                                } else {
                                    selectedLayouts.remove(layout)
                                }
                            }
                        ))
                        .toggleStyle(.checkbox)
                    }
                }
            }
            .frame(height: 150)
        }
    }
    
    private var buttonsSection: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .buttonStyle(.bordered)

            Spacer()

            Button("Save") {
                let newGroup = LayoutGroup(
                    id: group?.id ?? UUID(),
                    name: name,
                    layouts: Array(selectedLayouts),
                    color: selectedColor
                )
                onSave(newGroup)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.isEmpty || selectedLayouts.isEmpty)
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red, green, blue: UInt64

        switch hex.count {
        case 6:
            (red, green, blue) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (red, green, blue) = (0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: 1
        )
    }
}
