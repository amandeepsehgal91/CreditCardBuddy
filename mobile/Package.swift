// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CreditCardBuddy",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .macCatalyst(.v17)
    ],
    products: [
        .executable(
            name: "CreditCardBuddy",
            targets: ["CreditCardBuddy"]
        )
    ],
    targets: [
        .executableTarget(
            name: "CreditCardBuddy",
            path: "./",
            exclude: ["README.md"],
            sources: ["Models", "ViewModels", "Views", "Services", "App"],
            swiftSettings: [
                .define("SWIFTUI_AVAILABLE")
            ]
        )
    ]
)
