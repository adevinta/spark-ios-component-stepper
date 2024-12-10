// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// swiftlint:disable all
let package = Package(
    name: "SparkStepper",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SparkStepper",
            targets: ["SparkStepper"]
        ),
        .library(
            name: "SparkStepperTesting",
            targets: ["SparkStepperTesting"]
        )
    ],
    dependencies: [
       .package(
           url: "https://github.com/adevinta/spark-ios-common.git",
           // path: "../spark-ios-common"
           /*version*/ "0.0.1"..."999.999.999"
       ),
       .package(
           url: "https://github.com/adevinta/spark-ios-theming.git",
           // path: "../spark-ios-theming"
           /*version*/ "0.0.1"..."999.999.999"
       ),
       .package(
           url: "https://github.com/adevinta/spark-ios-component-button.git",
           // path: "../spark-ios-component-button"
           /*version*/ "0.0.1"..."999.999.999"
       )
    ],
    targets: [
        .target(
            name: "SparkStepper",
            dependencies: [
                .product(
                    name: "SparkCommon",
                    package: "spark-ios-common"
                ),
                .product(
                    name: "SparkTheming",
                    package: "spark-ios-theming"
                ),
                .product(
                    name: "SparkButton",
                    package: "spark-ios-component-button"
                )
            ],
            path: "Sources/Core"
        ),
        .target(
            name: "SparkStepperTesting",
            dependencies: [
                "SparkStepper",
                .product(
                    name: "SparkCommon",
                    package: "spark-ios-common"
                ),
                .product(
                    name: "SparkCommonTesting",
                    package: "spark-ios-common"
                ),
                .product(
                    name: "SparkThemingTesting",
                    package: "spark-ios-theming"
                ),
                .product(
                    name: "SparkTheme",
                    package: "spark-ios-theming"
                )
            ],
            path: "Sources/Testing"
        ),
        .testTarget(
            name: "SparkStepperUnitTests",
            dependencies: [
                "SparkStepper",
                "SparkStepperTesting",
                .product(
                    name: "SparkCommonTesting",
                    package: "spark-ios-common"
                ),
                .product(
                    name: "SparkThemingTesting",
                    package: "spark-ios-theming"
                )
            ],
            path: "Tests/UnitTests"
        ),
        .testTarget(
            name: "SparkStepperSnapshotTests",
            dependencies: [
                "SparkStepper",
                "SparkStepperTesting",
                .product(
                    name: "SparkCommonSnapshotTesting",
                    package: "spark-ios-common"
                ),
            ],
            path: "Tests/SnapshotTests"
        ),
    ]
)
