# Create New Executable

Navigate to the Package Directory.  

Run
```shell
swift build --product AutomatedAppVersioning -c release
```

Navigate to `PackageDeal/.build/arm64-apple-macosx/`  

Take the binary file and add it to `PackageDeal/AutomatedAppVersioning/Executable/versioning.artifactbundle/`  

Update the Version number  

Reset the package cache
