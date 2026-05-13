// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CreditCardBuddy",
    platforms: [
        .iOS(.v17),
        .macCatalyst(.v17)
    ],
    products: [
        .library(
            name: "CreditCardBuddy",
            targets: ["CreditCardBuddy"]
        )
    ],
    targets: [
        .target(
            name: "CreditCardBuddy",
            path: "./",
            exclude: ["README.md"],
            sources: ["Models", "ViewModels", "Views"],
            swiftSettings: [
                .define("SWIFTUI_AVAILABLE")
            ]
        )
    ]
)
