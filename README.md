# eyezon-sdk

## Интеграция SDK
Через CocoaPods
```ruby
pod 'EyezonSDK'
```

Через SPM

```// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/Eyezonteam/ios-sdk.git", .branch("dev")),
    ]
)
```
Теперь где нужно делаем `import EyezonSDK`
