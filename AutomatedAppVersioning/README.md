# AutomatedAppVersioning Plugin

AutomatedAppVersioning is an SPM plugin for automated app versioning during the build process. This plugin helps manage versioning in your Swift projects by automatically updating your app's version and build numbers based on Git tags and branch information.

## Table of Contents

1. [Installation](#installation)
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

## Installation

To install AutomatedAppVersioning as an SPM plugin, follow these steps:

```bash
$ swift build -c release
$ cp -f .build/release/AutomatedAppVersioningPlugin /usr/local/bin
```

Make sure to have Swift installed on your machine.

## Usage

After installation, you can use AutomatedAppVersioningPlugin by adding it as a build tool in your Swift project's Package.swift file:

```swift
import PackageDescription

let package = Package(
    name: "YourProject",
    ...
    targets: [
        ...
        .executableTarget(
            name: "YourAppTarget",
            ...
            dependencies: [
                .product(name: "PackagePlugin", package: "PackagePlugin"),
                .product(name: "AutomatedAppVersioning", package: "AutomatedAppVersioningPlugin"),
            ]
        ),
    ]
)
```

Then, add the following script phase to your Xcode project:

```swift
scripts/RunAutomatedAppVersioningPlugin.swift
```

## Configuration

AutomatedAppVersioningPlugin supports the following configuration options:

- `test-flag`: Specify a custom flag for test builds.
- `patch-branch-flag`: Specify a custom flag for hotfix branches.

Example:

```bash
$ swift run AutomatedAppVersioningPlugin --test-flag=TEST --patch-branch-flag=HOTFIX
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
