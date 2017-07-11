import PackageDescription

let package = Package(
    name: "SwiftyJSONModel",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 16)
    ]
)
