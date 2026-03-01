import Testing
import Foundation
@testable import LanguageFlag

/// Test suite for Layout Group functionality
@Suite("Layout Group Tests")
struct LayoutGroupTests {
    
    // MARK: - LayoutGroup Model Tests
    
    @Suite("Layout Group Model")
    struct LayoutGroupModelTests {
        
        @Test("Create layout group with defaults")
        func testCreateGroupWithDefaults() async throws {
            let group = LayoutGroup(name: "Work", layouts: ["US", "French"])
            
            #expect(group.name == "Work")
            #expect(group.layouts.count == 2)
            #expect(group.color == "#007AFF", "Should use default blue color")
            #expect(group.id != UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
        }
        
        @Test("Create layout group with custom color")
        func testCreateGroupWithCustomColor() async throws {
            let group = LayoutGroup(name: "Personal", layouts: [], color: "#FF0000")
            
            #expect(group.color == "#FF0000", "Should use custom color")
        }
        
        @Test("Layout group equality")
        func testGroupEquality() async throws {
            let id = UUID()
            let group1 = LayoutGroup(id: id, name: "Work", layouts: ["US"])
            let group2 = LayoutGroup(id: id, name: "Work", layouts: ["US"])
            
            #expect(group1 == group2, "Groups with same ID should be equal")
        }
        
        @Test("Layout group inequality")
        func testGroupInequality() async throws {
            let group1 = LayoutGroup(name: "Work", layouts: ["US"])
            let group2 = LayoutGroup(name: "Work", layouts: ["US"])
            
            #expect(group1 != group2, "Groups with different IDs should not be equal")
        }
        
        @Test("Layout group is Codable")
        func testGroupCodable() async throws {
            let group = LayoutGroup(name: "Work", layouts: ["US", "French"], color: "#FF0000")
            
            let encoded = try JSONEncoder().encode(group)
            let decoded = try JSONDecoder().decode(LayoutGroup.self, from: encoded)
            
            #expect(decoded.name == group.name)
            #expect(decoded.layouts == group.layouts)
            #expect(decoded.color == group.color)
        }
    }
    
    // MARK: - LayoutGroupManager Tests
    
    @Suite("Layout Group Manager")
    struct LayoutGroupManagerTests {
        
        @Test("Manager initializes with default groups")
        func testDefaultGroupsInitialization() async throws {
            let mockDefaults = MockUserDefaults()
            let manager = LayoutGroupManager(defaults: mockDefaults)
            
            let groups = manager.getGroups()
            #expect(groups.count == 3, "Should have 3 default groups")
            
            let groupNames = groups.map { $0.name }
            #expect(groupNames.contains("Work"))
            #expect(groupNames.contains("Personal"))
            #expect(groupNames.contains("Programming"))
        }
        
        @Test("Save new group")
        func testSaveNewGroup() async throws {
            let mockDefaults = MockUserDefaults()
            let manager = LayoutGroupManager(defaults: mockDefaults)
            
            let newGroup = LayoutGroup(name: "Gaming", layouts: ["US", "Korean"], color: "#FF0000")
            manager.saveGroup(newGroup)
            
            let groups = manager.getGroups()
            #expect(groups.contains(where: { $0.name == "Gaming" }), "Should contain new group")
        }
        
        @Test("Update existing group")
        func testUpdateExistingGroup() async throws {
            let mockDefaults = MockUserDefaults()
            let manager = LayoutGroupManager(defaults: mockDefaults)
            
            // Get an existing group
            var groups = manager.getGroups()
            var workGroup = groups.first { $0.name == "Work" }!
            
            // Modify it
            workGroup.layouts = ["US", "French", "German"]
            manager.saveGroup(workGroup)
            
            // Verify update
            groups = manager.getGroups()
            let updatedGroup = groups.first { $0.id == workGroup.id }
            #expect(updatedGroup?.layouts.count == 3, "Should have updated layouts")
        }
        
        @Test("Delete group")
        func testDeleteGroup() async throws {
            let mockDefaults = MockUserDefaults()
            let manager = LayoutGroupManager(defaults: mockDefaults)
            
            let groups = manager.getGroups()
            let initialCount = groups.count
            
            // Delete a group
            if let groupToDelete = groups.first {
                manager.deleteGroup(groupToDelete)
                
                let remainingGroups = manager.getGroups()
                #expect(remainingGroups.count == initialCount - 1, "Should have one less group")
                #expect(!remainingGroups.contains(where: { $0.id == groupToDelete.id }), "Deleted group should not exist")
            }
        }
        
        @Test("Get groups returns empty array when no groups")
        func testGetGroupsEmpty() async throws {
            let mockDefaults = MockUserDefaults()
            mockDefaults.clearAll()
            
            // Create manager but immediately delete all groups
            let manager = LayoutGroupManager(defaults: mockDefaults)
            let groups = manager.getGroups()
            
            for group in groups {
                manager.deleteGroup(group)
            }
            
            #expect(manager.getGroups().isEmpty, "Should return empty array")
        }
    }
    
    // MARK: - Active Group Tests
    
    @Suite("Active Group Management")
    struct ActiveGroupTests {
        
        @Test("Active group is nil by default")
        func testActiveGroupNilByDefault() async throws {
            let mockDefaults = MockUserDefaults()
            let manager = LayoutGroupManager(defaults: mockDefaults)
            
            #expect(manager.activeGroup == nil, "Active group should be nil initially")
        }
        
        @Test("Set active group")
        func testSetActiveGroup() async throws {
            let mockDefaults = MockUserDefaults()
            let manager = LayoutGroupManager(defaults: mockDefaults)
            
            let groups = manager.getGroups()
            let workGroup = groups.first { $0.name == "Work" }!
            
            manager.activeGroup = workGroup
            
            #expect(manager.activeGroup?.id == workGroup.id, "Active group should be set")
        }
        
        @Test("Active group persists")
        func testActiveGroupPersistence() async throws {
            let mockDefaults = MockUserDefaults()
            let manager1 = LayoutGroupManager(defaults: mockDefaults)
            
            let groups = manager1.getGroups()
            let workGroup = groups.first { $0.name == "Work" }!
            manager1.activeGroup = workGroup
            
            // Create new manager instance - should load saved active group
            let manager2 = LayoutGroupManager(defaults: mockDefaults)
            #expect(manager2.activeGroup?.id == workGroup.id, "Active group should persist")
        }
        
        @Test("Clear active group")
        func testClearActiveGroup() async throws {
            let mockDefaults = MockUserDefaults()
            let manager = LayoutGroupManager(defaults: mockDefaults)
            
            // Set active group
            let groups = manager.getGroups()
            manager.activeGroup = groups.first
            
            // Clear it
            manager.activeGroup = nil
            
            #expect(manager.activeGroup == nil, "Active group should be cleared")
        }
        
        @Test("Deleting active group clears it")
        func testDeleteActiveGroupClearsIt() async throws {
            let mockDefaults = MockUserDefaults()
            let manager = LayoutGroupManager(defaults: mockDefaults)
            
            let groups = manager.getGroups()
            let workGroup = groups.first { $0.name == "Work" }!
            
            manager.activeGroup = workGroup
            manager.deleteGroup(workGroup)
            
            #expect(manager.activeGroup == nil, "Deleting active group should clear it")
        }
        
        @Test("Deleting non-active group keeps active group")
        func testDeleteNonActiveGroup() async throws {
            let mockDefaults = MockUserDefaults()
            let manager = LayoutGroupManager(defaults: mockDefaults)
            
            let groups = manager.getGroups()
            let workGroup = groups.first { $0.name == "Work" }!
            let personalGroup = groups.first { $0.name == "Personal" }!
            
            manager.activeGroup = workGroup
            manager.deleteGroup(personalGroup)
            
            #expect(manager.activeGroup?.id == workGroup.id, "Active group should remain")
        }
    }
    
    // MARK: - Group Content Tests
    
    @Suite("Group Layout Management")
    struct GroupLayoutTests {
        
        @Test("Empty group layouts")
        func testEmptyGroupLayouts() async throws {
            let group = LayoutGroup(name: "Empty", layouts: [])
            #expect(group.layouts.isEmpty, "Layouts should be empty")
        }
        
        @Test("Group with multiple layouts")
        func testMultipleLayouts() async throws {
            let layouts = ["US", "French", "German", "Spanish", "Japanese"]
            let group = LayoutGroup(name: "Multilingual", layouts: layouts)
            
            #expect(group.layouts.count == 5, "Should have 5 layouts")
            #expect(group.layouts == layouts, "Layouts should match")
        }
        
        @Test("Modify group layouts")
        func testModifyGroupLayouts() async throws {
            let mockDefaults = MockUserDefaults()
            let manager = LayoutGroupManager(defaults: mockDefaults)
            
            var groups = manager.getGroups()
            var workGroup = groups.first { $0.name == "Work" }!
            
            // Add layouts
            workGroup.layouts = ["US", "French"]
            manager.saveGroup(workGroup)
            
            // Verify
            groups = manager.getGroups()
            let updatedGroup = groups.first { $0.id == workGroup.id }!
            #expect(updatedGroup.layouts.contains("US"))
            #expect(updatedGroup.layouts.contains("French"))
        }
        
        @Test("Duplicate layouts in group")
        func testDuplicateLayouts() async throws {
            let group = LayoutGroup(name: "Test", layouts: ["US", "US", "French"])
            
            #expect(group.layouts.count == 3, "Should allow duplicates")
        }
    }
    
    // MARK: - Group Color Tests
    
    @Suite("Group Colors")
    struct GroupColorTests {
        
        @Test("Default colors are set")
        func testDefaultColors() async throws {
            let mockDefaults = MockUserDefaults()
            let manager = LayoutGroupManager(defaults: mockDefaults)
            
            let groups = manager.getGroups()
            
            for group in groups {
                #expect(!group.color.isEmpty, "Color should not be empty")
                #expect(group.color.hasPrefix("#"), "Color should be hex format")
            }
        }
        
        @Test("Custom colors are preserved")
        func testCustomColors() async throws {
            let mockDefaults = MockUserDefaults()
            let manager = LayoutGroupManager(defaults: mockDefaults)
            
            let customColor = "#FF5733"
            let group = LayoutGroup(name: "Custom", layouts: [], color: customColor)
            manager.saveGroup(group)
            
            let savedGroup = manager.getGroups().first { $0.id == group.id }
            #expect(savedGroup?.color == customColor, "Custom color should be preserved")
        }
    }
    
    // MARK: - Persistence Tests
    
    @Suite("Group Persistence")
    struct GroupPersistenceTests {
        
        @Test("Groups persist across manager instances")
        func testGroupsPersist() async throws {
            let mockDefaults = MockUserDefaults()
            
            // Create first manager and add group
            let manager1 = LayoutGroupManager(defaults: mockDefaults)
            let newGroup = LayoutGroup(name: "Test", layouts: ["US"])
            manager1.saveGroup(newGroup)
            
            // Create second manager - should load saved groups
            let manager2 = LayoutGroupManager(defaults: mockDefaults)
            let groups = manager2.getGroups()
            
            #expect(groups.contains(where: { $0.name == "Test" }), "Groups should persist")
        }
        
        @Test("Group modifications persist")
        func testModificationsPersist() async throws {
            let mockDefaults = MockUserDefaults()
            
            let manager1 = LayoutGroupManager(defaults: mockDefaults)
            var groups = manager1.getGroups()
            var workGroup = groups.first { $0.name == "Work" }!
            workGroup.layouts = ["Modified"]
            manager1.saveGroup(workGroup)
            
            let manager2 = LayoutGroupManager(defaults: mockDefaults)
            let loadedGroup = manager2.getGroups().first { $0.id == workGroup.id }
            
            #expect(loadedGroup?.layouts.first == "Modified", "Modifications should persist")
        }
    }
}
