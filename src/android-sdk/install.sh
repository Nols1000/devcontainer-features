#!/bin/bash
set -e

URL_SDK="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

# Setup options
PLATFORM="${platform:-"34"}"
BUILD_TOOLS="${build_tools:-"34.0.0"}"
COMMAND_LINE_TOOLS="${command_line_tools-"11076708"}"

# Check if packages are installed and install them if not
check_packages() {
  if ! dpkg -s "$@" >/dev/null 2>&1; then
    apt-get update -y
    apt-get -y install --no-install-recommends "$@"
  fi
}

# Install Android SDK
install() {
  # Prepare install folder
  mkdir -p "$ANDROID_HOME"
  chown -R "$_REMOTE_USER:$_REMOTE_USER" "$ANDROID_HOME"

  # Login to remote user
  su - "$_REMOTE_USER"

  # Download and install command line tools
  curl -L -o "command_line_tools.zip" "https://dl.google.com/android/repository/commandlinetools-linux-${COMMAND_LINE_TOOLS}_latest.zip"
  unzip -q "command_line_tools.zip"
  mkdir -p "$ANDROID_HOME"/cmdline-tools
  mv cmdline-tools "$ANDROID_HOME"/cmdline-tools/latest
  rm -f "command_line_tools.zip"

  # Add command line tools to $PATH
  export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"

  # Update sdkmanager
  yes | sdkmanager --update

  # Install platform-tools, build-tools, platforms
  yes | sdkmanager "platform-tools" "build-tools;${BUILD_TOOLS}" "platforms;android-${PLATFORM}"

  echo "Installed Android:"
  echo "  platform:    $PLATFORM"
  echo "  build-tools: $BUILD_TOOLS"
}

check_packages curl ca-certificates unzip
install


