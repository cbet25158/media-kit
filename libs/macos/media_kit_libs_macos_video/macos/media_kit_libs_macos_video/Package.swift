// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let libmpvTargets = [
    "Ass",
    "Avcodec",
    "Avfilter",
    "Avformat",
    "Avutil",
    "Dav1d",
    "Freetype",
    "Fribidi",
    "Harfbuzz",
    "Mbedcrypto",
    "Mbedtls",
    "Mbedx509",
    "Mpv",
    "Png16",
    "Swresample",
    "Swscale",
    "Uchardet",
    "Xml2"
]

let libmpvArtifactBase = "https://github.com/cbet25158/libmpv-darwin-build/releases/download/1.0.0/libmpv-xcframeworks_1.0.0_macos-universal-video-default"
let libmpvChecksums = [
    "Ass": "c872941655aebd5bb4a99caf123cb19d3fb1bf12d86ef7e3cff86a1799e1cd79",
    "Avcodec": "c5e2627a88b7e9f9e1a3590dd3c0d644ca430cdce7c21579f178d1002ed63573",
    "Avfilter": "d33357734e3f9b000294e136695b36f763d777dd6cdc3c6e9ec407456d284b86",
    "Avformat": "780963b540fae97f18afe6cace679098e6f3553d8b2ebe2fc56bb3369482d593",
    "Avutil": "adc5d4b0b28a4afde5a6823ce3c90467c770f08b717338429dcba60b4212a3a1",
    "Dav1d": "bef7c4084e8d1160b475f6dd2c23328b8b303a95ac39c4abafa070b0d9396225",
    "Freetype": "583d411f0454c7e9abc86f8cd22f52cfab5892fe654ce75a7b50c3e5860c1d7d",
    "Fribidi": "2fc0afd8504078b9b95fe7e8cca99dd898f8b5e8f00962dc1878bfcd42a96678",
    "Harfbuzz": "9c0a2a64f24ccc589ba920eb906dfb3c0929502984f8519a72915a85b162c7dc",
    "Mbedcrypto": "4e754a2955ed127916a172d6a595bc3c3dc669294893eace2579f36d9b3c596d",
    "Mbedtls": "c595893a3df6f391b4c24aec2d9d21804b3af1370c60031099bbc2faf19c8fa9",
    "Mbedx509": "1947315cef22fa742a1f4260e86e56e5ece6db99815dcbed54de6bf4781795e8",
    "Mpv": "6de423c2bfaf4a65d2eb1f4e58325478b7f85fccb766159e75ac6c14ca241df4",
    "Png16": "c6a5bde6af5b00ea67142004d9bbd8c1dd2c2449193d31ab98a3c357b8bd7ec9",
    "Swresample": "9da67ec49c8936c85c60eac5ad9d2570fc84f9ed91fc687db267b7fe96f5e3c1",
    "Swscale": "f3f833b2c4b7aecdbce1bfcea0c3df85515944941b594809d392b1b7d6d16e0d",
    "Uchardet": "13eae3073e1b46805e7adbbc4bc1cfc4e21b7e1a79eebd173c4bda774dc2cc1a",
    "Xml2": "1405ce859779f357684f57d9fda7d18a94657e925362e2452f0c44c8d33210ed"
]
let libmpvProductTargets: [String] = ["media_kit_libs_macos_video"] + libmpvTargets

let package = Package(
    name: "media_kit_libs_macos_video",
    platforms: [
        .macOS("10.9")
    ],
    products: [
        .library(name: "media-kit-libs-macos-video", targets: libmpvProductTargets),
        .library(name: "Mpv", targets: ["Mpv"])
    ],
    dependencies: [],
    targets: libmpvTargets.map { framework in
        .binaryTarget(
            name: framework,
            url: "\(libmpvArtifactBase)_\(framework).zip",
            checksum: libmpvChecksums[framework]!
        )
    } + [
        .target(
            name: "media_kit_libs_macos_video",
            dependencies: libmpvTargets.map { framework in .target(name: framework) },
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
