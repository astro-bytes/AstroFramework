# AutomatedAppVersioning Plugin

AutomatedAppVersioning is an SPM plugin for automated app versioning during the build process. This plugin helps manage versioning in your Swift projects by automatically updating your app's version and build numbers based on Git tags and branch information.

## Table of Contents

1. [Integration](#integration)
2. [Usage](#usage)
3. [Configuration](#configuration)
4. [Features](#features)
5. [Compatibility](#compatibility)
6. [Troubleshooting](#troubleshooting)
7. [Contributing](#contributing)
8. [License](#license)
9. [Changelog](#changelog)
10. [Credits](#credits)
11. [Contact Information](#contact-information)

## Integration
### Xcode Project

### Swift Package
Add the package as a dependency in Package.swift:
```swift
.package(url: "https://github.com/astro-bytes/PackageDeal.git", from: "1.0.0")
```

Add the plugin to the executable target (optional not recommended):
```swift
.plugin(name: "AutomatedAppVersioning", package: "PackageDeal")
```

Similarly like so
```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/astro-bytes/PackageDeal.git", from: "1.0.0")
    ],
    ...
    targets: [
        .executableTarget(
            name: "TestPackage",
            plugins: [
                .plugin(name: "AutomatedAppVersioning", package: "PackageDeal") // Optional & Not recommended
            ]
        ),
    ],
    ...
)
```

## Usage
### Running from Xcode
Run the Script by right clicking your package and selecting the command, providing arguments if desired, selecting run
![image](https://github.com/astro-bytes/PackageDeal/assets/56183563/de737fb5-be39-4c7d-86bb-f3853e073724)
![image](https://github.com/astro-bytes/PackageDeal/assets/56183563/d08dbfca-fced-4c7d-a215-45e2a236809f)


### Running from Terminal
Navigate to the package or project's root then run
```bash
swift package automated-app-versioning
```

## Configuration

AutomatedAppVersioningPlugin supports the following configuration options:

- `test-flag`: Specify a custom flag for test builds. Defualts to `T` when not provided.
- `patch-branch-flag`: Specify a custom flag for hotfix branches. Defaults to `HF` when not provided.

Default Flag Examples:
```
// git branch hot fix name
HF-<branch name>

// Test Tag
T-<Major>.<Minor>.<Patch>
```

Example:
```bash
swift package automated-app-versioning --test-flag=TEST --patch-branch-flag=HOTFIX
```

## Features

- **Automated Versioning:** Automatically calculates and updates the app version and build number based on Git tags and branch information.
- **Customizable:** Configure flags for test builds and hotfix branches to suit your project's needs.

## Compatibility

AutomatedAppVersioningPlugin is compatible with Swift Package Manager.

## Troubleshooting

If you encounter any issues or have questions, please check the [Troubleshooting](#troubleshooting) section in the documentation.

## Contributing

We welcome contributions! If you find any bugs or have ideas for improvements, please open an issue or submit a pull request.

For more information, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

AutomatedAppVersioningPlugin is released under the [MIT License](LICENSE).

## Changelog

### Version 1.0.0

- Initial release.

## Credits

- [Porter McGary](https://github.com/portermcgary)

## Contact Information

For support or inquiries, please contact [Porter McGary](https://github.com/portermcgary).
