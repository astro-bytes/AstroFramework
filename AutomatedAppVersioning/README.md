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
Add the package as a dependency to the project by searching for `https://github.com/astro-bytes/PackageDeal.git`
![image](https://github.com/astro-bytes/PackageDeal/assets/56183563/6d69aa2b-6761-4a42-bb34-324b3dee10a8)

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

### Running from Terminal
Navigate to the package or project's root then run
```bash
swift package automated-app-versioning
```

## Configuration
### Plugin Configurations
AutomatedAppVersioningPlugin supports the following configuration options:

- `config-name`: Specify the name of the xcconfig file. Defaults to `version-info` when not provided.
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
swift package automated-app-versioning --test-flag=TEST --patch-branch-flag=HOTFIX --config-name=AppConfig
```

### Project Configuration
Due to the nature of this plugin there are additional configurations that are needed to take full advantage after the initial run of the plugin.

**1. Integrate the Config File**
This can be done in two ways.  
  A. Using the configuration file generated as your main application configuration.  
     *This method is not recommended when using more than one `xcconfig` file or if you intend to add additional values to your configuration file (defer to option B.).*  
     
  - Navigate to your project file in Xcode
    ![image](https://github.com/astro-bytes/PackageDeal/assets/56183563/78a4a63e-687c-42fc-afa4-657a8b9fd5ff)
  - Select the Configuration file for the appropriate Configuration & Scheme & Project and/or Target
    ![image](https://github.com/astro-bytes/PackageDeal/assets/56183563/93af3d98-2be3-4aca-8ec9-ccca5e08d0c8)

  B. Open your main application configuration file and add this import to it `#import "<name-of-versioning-config>.xcconfig"`  
     **NOTE:** If you do not provide a name override the import statement will look something like this `#import "version-info.xcconfig"`  
     **WARNING:** The import should point to the path relative to the config file that it is in.

**2. Add Custom Values to Build Settings**
  - Navigate to the target's Build Settings that the plugin is used for. (Typically this would be your application Target but there can be more than one depending on your setup)
  - Filter by `Versioning`
  - Replace the string valur for the `Current Project Version` with `$(APP_VERSION)`
  - Replace the string valur for the `Marketing Version` with `$(BUILD_NUMBER)`

When done properly the value should reflect as the new version values.
![image](https://github.com/astro-bytes/PackageDeal/assets/56183563/5996de70-3090-4ed3-ad6f-150efebf0085)


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
