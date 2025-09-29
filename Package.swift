// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "LabelledPreorder",
  products: [
    .library(
      name: "LabelledPreorder",
      targets: ["LabelledPreorder"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "LabelledPreorder"
    ),
    .testTarget(
      name: "LabelledPreorderTests",
      dependencies: ["LabelledPreorder"]
    ),
  ]
)
