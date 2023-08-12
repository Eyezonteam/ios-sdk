// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "EyezonSDK",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "EyezonSDK",
            targets: ["EyezonSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.2.0")
    ],
    targets: [
        .target(
            name: "EyezonSDK",
            dependencies: [
                "SwiftyJSON",
                .product(name: "Lottie", package: "lottie-spm")
            ],
            path: "EyezonSDK",
            exclude: [
                "build",
                "Pods",
                "Podfile",
                "Podfile.lock",
                "EyezonSDK.podspec"
            ],  // Exclude 'build' and 'Pods' directories and pod files
            sources: nil,
            resources: [.process("EyezonSDK/Sources/Media.xcassets")]
        )
    ]
)
