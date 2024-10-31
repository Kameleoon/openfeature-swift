// swift-tools-version:5.3

import PackageDescription
let package = Package(
    name: "KameleoonOpenfeature",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "KameleoonOpenfeature",
            targets: ["KameleoonOpenfeature"])
    ],
    targets: [
        .binaryTarget(
            name: "KameleoonOpenfeature",
            url: "https://github.com/Kameleoon/openfeature-swift/releases/download/0.0.1/kameleoon-openfeature-swift-0.0.1.zip",
            checksum: "1587a27b0560b35f55c0300c7ea4a50bd07fd9374abfe1cf8296f2b1f1951ae9"
        )
    ])
