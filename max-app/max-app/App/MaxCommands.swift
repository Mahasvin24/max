// Provenance: HAND-BUILT. Built from: Commands, FocusedValues.
import SwiftUI

extension FocusedValues {
    @Entry var newChat: (() -> Void)?
    @Entry var toggleMaxSidebar: (() -> Void)?
}

struct MaxCommands: Commands {
    @FocusedValue(\.newChat) private var newChat
    @FocusedValue(\.toggleMaxSidebar) private var toggleSidebar

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Chat") { newChat?() }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .disabled(newChat == nil)
        }
        CommandGroup(before: .sidebar) {
            Button("Toggle Sidebar") { toggleSidebar?() }
                .keyboardShortcut("s", modifiers: [.command, .control])
                .disabled(toggleSidebar == nil)
        }
    }
}
