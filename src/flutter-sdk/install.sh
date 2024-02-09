#!/bin/bash
set -e

OS_NAME=linux
MANIFEST_BASE_URL="https://storage.googleapis.com/flutter_infra_release/releases"
MANIFEST_JSON_PATH="releases_$OS_NAME.json"
MANIFEST_URL="$MANIFEST_BASE_URL/$MANIFEST_JSON_PATH"

# Setup options
CHANNEL="${channel:-"stable"}"
VERSION="${version:-"any"}"
ARCH="${arch:-"x64"}"
DISABLE_ANALYTICS="${disable_analytics:-"true"}"

# Check if packages are installed and install them if not
check_packages() {
  if ! dpkg -s "$@" >/dev/null 2>&1; then
    DEBIAN_FRONTEND=noninteractive apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends "$@"
  fi
}

filter_by_channel() {
	jq --arg channel "$1" '[.releases[] | select($channel == "any" or .channel == $channel)]'
}

filter_by_arch() {
	jq --arg arch "$1" '[.[] | select(.dart_sdk_arch == $arch or ($arch == "x64" and (has("dart_sdk_arch") | not)))]'
}

filter_by_version() {
	jq --arg version "$1" '.[].version |= gsub("^v"; "") | (if $version == "any" then .[0] else (map(select(.version == $version or (.version | startswith(($version | sub("\\.x$"; "")) + ".")) and .version != $version)) | .[0]) end)'
}

not_found_error() {
	echo "Unable to determine Flutter version for channel: $1 version: $2 architecture: $3"
}

transform_path() {
	if [[ "$OS_NAME" == windows ]]; then
		echo "$1" | sed -e 's/^\///' -e 's/\//\\/g'
	else
		echo "$1"
	fi
}

download_archive() {
	archive_url="$MANIFEST_BASE_URL/$1"
	archive_name=$(basename "$1")
	archive_local="$archive_name"

	curl --connect-timeout 15 --retry 5 "$archive_url" >"$archive_local"

	mkdir -p "$2"

	if [[ "$archive_name" == *zip ]]; then
		EXTRACT_PATH="_unzip_temp"
		unzip -q -o "$archive_local" -d "$EXTRACT_PATH"
		# Remove the folder again so that the move command can do a simple rename\
		# instead of moving the content into the target folder.
		# This is a little bit of a hack since the "mv --no-target-directory"
		# linux option is not available here
		rm -r "$2"
		mv "$EXTRACT_PATH"/flutter "$2"
		rm -r "$EXTRACT_PATH"
	else
		tar xf "$archive_local" -C "$2" --strip-components=1
	fi

	rm "$archive_local"
}

# Install Flutter SDK
install() {
  # Resolve version
  RELEASE_MANIFEST=$(curl --silent --connect-timeout 15 --retry 5 "$MANIFEST_URL")
  
  if [[ "$CHANNEL" == "master" || "$CHANNEL" == "main" ]]; then
    VERSION_MANIFEST="{\"channel\":\"$CHANNEL\",\"version\":\"$VERSION\",\"dart_sdk_arch\":\"$ARCH\",\"hash\":\"$CHANNEL\",\"sha256\":\"$CHANNEL\"}"
  else
    VERSION_MANIFEST=$(echo "$RELEASE_MANIFEST" | filter_by_channel "$CHANNEL" | filter_by_arch "$ARCH" | filter_by_version "$VERSION")
  fi

  if [[ "$VERSION_MANIFEST" == *null* ]]; then
    not_found_error "$CHANNEL" "$VERSION" "$ARCH"
    exit 1
  fi

  # Prepare install folder
  mkdir -p "$FLUTTER_HOME"
  git config --global --add safe.directory "$FLUTTER_HOME"

  # Login to remote user
  su - "$_REMOTE_USER"

  if [[ "$CHANNEL" == "master" || "$CHANNEL" == "main" ]]; then
		git clone -b "$CHANNEL" https://github.com/flutter/flutter.git "$FLUTTER_HOME"
		if [[ "$VERSION" != "any" ]]; then
			git config --global --add safe.directory "$FLUTTER_HOME"
			(cd "$FLUTTER_HOME" && git checkout "$VERSION")
		fi
	else
		archive_url=$(echo "$VERSION_MANIFEST" | jq -r '.archive')
		download_archive "$archive_url" "$FLUTTER_HOME"
	fi

  version_info=$(echo "$VERSION_MANIFEST" | jq -j '.channel,":",.version,":",.dart_sdk_arch // "x64"')

	info_channel=$(echo "$version_info" | awk -F ':' '{print $1}')
	info_version=$(echo "$version_info" | awk -F ':' '{print $2}')
	info_architecture=$(echo "$version_info" | awk -F ':' '{print $3}')

  if [ $DISABLE_ANALYTICS ]; then
    flutter --disable-analytics
    dart --disable-analytics
  fi


  chown -R "$_REMOTE_USER:$_REMOTE_USER" "$FLUTTER_HOME"

  echo "Installed Flutter:"
  echo "  channel: $info_channel"
  echo "  version: $info_version"
  echo "  arch:    $info_architecture"
}

check_packages bash ca-certificates clang cmake curl file git jq libgtk-3-dev ninja-build pkg-config unzip xz-utils zip
install


