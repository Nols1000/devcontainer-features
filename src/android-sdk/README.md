
# Android SDK (android-sdk)

A feature to set up the Android SDK for DevContainers, automating the creation of a consistent development environment with the necessary Android tools and platforms for seamless mobile application development.

## Example Usage

```json
"features": {
    "ghcr.io/Nols1000/devcontainer-features/android-sdk:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| platform | SDK platform version | string | 34 |
| build_tools | SDK build-tools version | string | 34.0.0 |
| command_line_tools | Command line tools version | string | 11076708 |

### Emulator

```json
{
  "name": "Flutter",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/common-utils": {},
    "ghcr.io/nols1000/devcontainer-features/android-sdk:0": {},
    "ghcr.io/nols1000/devcontainer-features/flutter-sdk:0": {}
  },
  "mounts": [
    "source=/tmp/.X11-unix,target=/tmp/.X11-unix,consistency=cached"
  ],
  "containerEnv": {
    "DISPLAY": "$DISPLAY"
  }
  // Use 'forwardPorts' to make a list of ports inside the container available locally.
  //"forwardPorts": [],
  // Uncomment to connect as a non-root user. See https://aka.ms/vscode-remote/containers/non-root.
  // "remoteUser": "vscode"
}
```

Install a system-image to create the emulator

```sh
sdkmanager "system-images;android-34;google_apis_playstore;x86_64"
```

or

```sh
sdkmanager "system-images;android-34;google_apis_playstore;arm64-v8a"
```

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/Nols1000/devcontainer-features/blob/main/src/android-sdk/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
