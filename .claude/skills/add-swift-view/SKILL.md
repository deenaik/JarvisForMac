---
name: add-swift-view
description: Add a new SwiftUI view to the native macOS app. Use when asked to create a new screen, panel, or UI component for the JarvisApp.
argument-hint: [view-name] [description]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Add a New SwiftUI View

Create a new view called `$0` in the JarvisApp native macOS app.

Description: $ARGUMENTS

## Steps

1. **Read existing views** in `JarvisApp/JarvisApp/Views/` as reference for the pattern
2. **Read `AppState.swift`** to understand available state and published properties
3. **Create the view file** at `JarvisApp/JarvisApp/Views/$0.swift`:
   - Use `@EnvironmentObject var appState: AppState` if the view needs app state
   - Follow SwiftUI conventions: struct conforming to `View`, `body` computed property
   - Use SF Symbols for icons (they're already used throughout the app)
   - Use `.ultraThinMaterial` or `Color(nsColor: .controlBackgroundColor)` for backgrounds to match existing design
4. **Add the file to the Xcode project**:
   - Read `JarvisApp/JarvisApp.xcodeproj/project.pbxproj`
   - Add a PBXFileReference for the new .swift file
   - Add a PBXBuildFile referencing it in the Sources build phase
   - Add the file reference to the Views group
   - Use unique IDs that don't conflict with existing ones (follow the pattern: `B10000XX` for file refs, `A10000XX` for build files)
5. **Wire the view** into the app where appropriate:
   - If it's a sub-view: reference it from `FloatingPanelView.swift` or another parent
   - If it's a new panel/window: wire it from `AppDelegate.swift`
   - If it's a settings view: add a menu item in `StatusMenuView.swift`
6. **Build and verify**: `cd JarvisApp && xcodebuild -scheme JarvisApp -configuration Debug build 2>&1 | grep -E "error:|BUILD"`

## Conventions

- Use `@MainActor` on any classes (views are structs, so this doesn't apply to them)
- Use `os.Logger` for debug logging, not `print()`
- Use `@EnvironmentObject` for AppState access, not direct singleton references
- Match the existing visual style: rounded rectangles, subtle opacity, SF Symbols
- Keep views focused — extract sub-views into separate files when they grow complex
