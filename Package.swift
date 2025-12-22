// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// VLCKit 4.0.0a18 - Unified framework with native PiP support
// Checksum: 1b303d0a7144f4ea28435596f044daa2310a64fecb6968070fe658c15c54332b
let vlcBinary = Target.binaryTarget(
    name: "VLCKit-all",
    url: "https://github.com/yucelokan/vlckit-spm/releases/download/4.0.0a18/VLCKit-all.xcframework.zip",
    checksum: "1b303d0a7144f4ea28435596f044daa2310a64fecb6968070fe658c15c54332b"
)

let package = Package(
    name: "vlckit-spm",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14),
        .tvOS(.v14),
    ],
    products: [
        .library(
            name: "VLCKitSPM",
            targets: ["VLCKitSPM"]
        ),
    ],
    dependencies: [],
    targets: [
        vlcBinary,
        .target(
            name: "VLCKitSPM",
            dependencies: [
                .target(name: "VLCKit-all")
            ],
            linkerSettings: [
                // iOS & tvOS
                .linkedFramework("QuartzCore", .when(platforms: [.iOS, .tvOS])),
                .linkedFramework("CoreText", .when(platforms: [.iOS, .tvOS])),
                .linkedFramework("AVFoundation", .when(platforms: [.iOS, .tvOS, .macOS])),
                .linkedFramework("Security", .when(platforms: [.iOS, .tvOS])),
                .linkedFramework("CFNetwork", .when(platforms: [.iOS, .tvOS])),
                .linkedFramework("AudioToolbox", .when(platforms: [.iOS, .tvOS])),
                .linkedFramework("CoreGraphics", .when(platforms: [.iOS, .tvOS])),
                .linkedFramework("VideoToolbox", .when(platforms: [.iOS, .tvOS, .macOS])),
                .linkedFramework("CoreMedia", .when(platforms: [.iOS, .tvOS, .macOS])),
                // Metal for VLCKit 4.0 (replaced OpenGLES)
                .linkedFramework("Metal", .when(platforms: [.iOS, .tvOS, .macOS])),
                .linkedFramework("MetalKit", .when(platforms: [.iOS, .tvOS, .macOS])),
                // AVKit for PiP support
                .linkedFramework("AVKit", .when(platforms: [.iOS, .tvOS, .macOS])),
                // macOS
                .linkedFramework("Foundation", .when(platforms: [.macOS])),
                .linkedFramework("Cocoa", .when(platforms: [.macOS])),
                // Libraries
                .linkedLibrary("c++"),
                .linkedLibrary("xml2"),
                .linkedLibrary("z"),
                .linkedLibrary("bz2"),
                .linkedLibrary("iconv"),
            ]
        ),
    ]
)
