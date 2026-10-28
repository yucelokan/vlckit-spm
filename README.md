# VLCKit SPM

This is a Swift Package Manager compatible version of [VLCKit](https://code.videolan.org/videolan/VLCKit).
The `vlc372` branch distributes the official VLCKit 3.7.4 binaries (libVLC
3.0.24) for iOS, macOS and tvOS as a single Swift Package. The branch name is
historical; it tracks the latest VLCKit 3.x release.

### Installation
Add this repo to as a Swift Package dependency to your project
```
https://github.com/yucelokan/vlckit-spm
```

If using this in a swift package, add this repo as a dependency.
```
.package(url: "https://github.com/yucelokan/vlckit-spm.git", branch: "vlc372")
```

### Usage

To get started, import this library: `import VLCKitSPM`

See the [VLCKit documentation](https://videolan.videolan.me/VLCKit/) for more info on integration and usage for VLCKit.

### Building
Run `./generate.sh` to reproduce `dist/VLCKit-all.xcframework.zip` from
VideoLAN's official 3.7.4 iOS, tvOS and macOS archives. The archive names and
SHA-256 values are the ones VideoLAN's 3.7.4 podspecs document, and the script
refuses an archive whose SHA-256 differs. It prints the generated SwiftPM
checksum so the uploaded release asset can be pinned in `Package.swift`.
