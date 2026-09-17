// swift-tools-version: 6.2
import PackageDescription

// A dependency-free test target for the same chat state and transport sources used by Xcode.
let package = Package(
    name: "MaxChatState",
    platforms: [.macOS("26.4")],
    targets: [
        .target(
            name: "MaxChatState",
            path: "max-app",
            exclude: [
                "App", "Assets.xcassets", "ContentView.swift",
                "Features/BreakTimer", "Features/Sidebar", "Features/Chat/ChatScreen.swift",
                "Features/Chat/Components", "Shared/DesignSystem", "Shared/NotificationService.swift"
            ],
            sources: ["Features/Chat/ChatViewModel.swift", "Shared/APIClient.swift",
                      "Shared/Schemas.swift", "Shared/Errors.swift", "Shared/Constants.swift"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(name: "MaxChatStateTests", dependencies: ["MaxChatState"], path: "Tests")
    ],
    swiftLanguageModes: [.v5]
)
