import PackageDescription

let package = Package(
    name: "SwiftyJSONModel",
    targets: [
        Target(name: "SwiftyJSONModel", dependencies: []),
        Target(name: "Ccmark", dependencies: [])
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 7)
    ]
)
