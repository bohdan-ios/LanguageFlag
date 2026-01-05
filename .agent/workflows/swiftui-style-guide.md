---
description: SwiftUI View style guide for consistent code structure
---

# SwiftUI View Style Guide

## Structure Order
```swift
struct MyView: View {
    // MARK: - Variables
    // MARK: - Init
    // MARK: - Views
}

// MARK: - Private
private extension MyView { }
```

## Variables
- **Group by property wrapper**: `@EnvironmentObject`, `@StateObject`, `@ObservedObject`, `@Binding`, `@State`
- **Separate wrapper types** with blank line
- **All private** by default (use explicit `init` for external params)
- **No blank line** after `// MARK: -`

## Init
- **Each argument on new line**
- Required when view has external dependencies

## Views
- `body` calls `content` (not inline)
- **Extract sub-views** as private computed properties
- **Blank line between views** inside stacks

## Private Functions
- Place in `private extension MyView { }`

---

## Example

```swift
struct MyView: View {

    // MARK: - Variables
    @Binding private var selection: Item

    @State private var isExpanded = false

    private let title: String

    // MARK: - Init
    init(
        title: String,
        selection: Binding<Item>
    ) {
        self.title = title
        self._selection = selection
    }

    // MARK: - Views
    var body: some View {
        content
    }
    
    private var content: some View {
        VStack {
            headerView

            Divider()

            detailView
        }
    }
    
    private var headerView: some View {
        Text(title)
            .font(.headline)
    }
    
    private var detailView: some View {
        Text("Details")
    }
}

// MARK: - Private
private extension MyView {
    func handleTap() { }
}
```
