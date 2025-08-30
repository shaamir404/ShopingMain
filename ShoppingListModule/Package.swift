// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShoppingListModule",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "ShoppingListModule",
            targets: ["ShoppingListModule"]),
    ],
    dependencies: [
        // No external dependencies to keep it simple
    ],
    targets: [
        .target(
            name: "ShoppingListModule",
            dependencies: []),
        .testTarget(
            name: "ShoppingListModuleTests",
            dependencies: ["ShoppingListModule"]),
    ]
)
