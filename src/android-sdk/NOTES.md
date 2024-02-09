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