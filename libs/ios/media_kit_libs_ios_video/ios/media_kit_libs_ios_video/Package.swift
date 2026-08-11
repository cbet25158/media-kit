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

let libmpvArtifactBase = "https://github.com/cbet25158/libmpv-darwin-build/releases/download/1.0.0/libmpv-xcframeworks_1.0.0_ios-universal-video-default"
let libmpvChecksums = [
    "Ass": "2f810e8bb2ab5f86dae3d5e5927df30f5296b7325bb52200ac1a804d44388cdf",
    "Avcodec": "c213f4706cad937ac49c2f9e23f10ad9ee15825281ca08e13e28f907126728c4",
    "Avfilter": "ac33c3706f6fe70725f66d43618341e4ffbfd1cb6c0d10cab99c35605e3dab45",
    "Avformat": "7a40639d21fb1092347071e3a169c2ee6caf726b3fa2149b46e6fb386d20add6",
    "Avutil": "3b3471b82632fb07d4c21e005cef2ded473f37ca1a2db6062c3ddd06c498ec4b",
    "Dav1d": "336e2d1add9a7eb86afda85036b3260b34fa81016e7833f64bd77e586a39eaba",
    "Freetype": "cdb3d475a50c3dc6e75c8875a2d2227b0aa28f6e3d1603b7d15b1897efc79280",
    "Fribidi": "307c818ee59ed3d06df9ac773e0cd8b5440485ae19a73fb48a347be0a2b78d84",
    "Harfbuzz": "11b2c2a7a7757f5a72213ea5ed3cd16bc0acfa31e69616c600f77a9951f5b9fe",
    "Mbedcrypto": "af34f89c1cdc6a180e54de1f64406842e5fa6f798b8bee6a6c4bdb81ecc3b087",
    "Mbedtls": "e39d4934395acbf10227fe6857d79073e49ae6de3f7129dc1840d85a4bd69f06",
    "Mbedx509": "3281932c0665fcc46895fe20b6f2f3aa2214e7dba057a61167793c85b500045b",
    "Mpv": "9ae1989e42edb61e572f57da02f2c1ca68430ad61346c6ed9fe6bdc702077d60",
    "Png16": "d7488420a888c9e57b9a073d24b77d499f3de7ab45479f84501e2bad2668a204",
    "Swresample": "5d10677cd7081adc4a7cf0636a2f028c6b6678cdc8b62ec8e905039ebd168bcb",
    "Swscale": "70937c32b386dbe2396e7a4ba57ce0e04491487e11aa6198224506e6fb720158",
    "Uchardet": "1e2eb10518f7a254bfd355ef956593fe62814c2b221507d9f29931e368ae7b55",
    "Xml2": "7428c44a4aad4892a5bd2df0c33edd12930a86632c82ae4b2831e6e70c253ea1"
]
let libmpvProductTargets: [String] = ["media_kit_libs_ios_video"] + libmpvTargets

let package = Package(
    name: "media_kit_libs_ios_video",
    platforms: [
        .iOS("9.0")
    ],
    products: [
        .library(name: "media-kit-libs-ios-video", targets: libmpvProductTargets),
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
            name: "media_kit_libs_ios_video",
            dependencies: libmpvTargets.map { framework in .target(name: framework) },
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
