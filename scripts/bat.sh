#!/bin/bash

# Parse command line arguments
AUTO_YES=false
for arg in "$@"; do
  case $arg in
    -y|--yes)
      AUTO_YES=true
      shift
      ;;
  esac
done

# Check if bat is already installed
if command -v bat &> /dev/null; then
  CURRENT_VERSION=$(bat --version)
  CURRENT_VERSION_NUM=$(echo "$CURRENT_VERSION" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+")

  # Get latest release info from GitHub API without output
  echo "Fetching latest bat release information..."
  LATEST_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest |
                  grep "tag_name" |
                  cut -d '"' -f 4 |
                  sed 's/v//')

  if [ -z "$LATEST_VERSION" ]; then
    echo "Error: Could not determine the latest bat version."
    exit 1
  fi

  # Compare versions
  if [ "$CURRENT_VERSION_NUM" = "$LATEST_VERSION" ]; then
    echo "Latest version v$LATEST_VERSION already installed."
    exit 0
  fi

  if [ "$AUTO_YES" = false ]; then
    read -p "Do you want to replace $CURRENT_VERSION with v$LATEST_VERSION? (y/n): " choice
    case "$choice" in
      y|Y ) echo "Proceeding with installation...";;
      * ) echo "Installation cancelled."; exit 0;;
    esac
  else
    echo "Auto-yes flag detected. Proceeding with installation..."
  fi
else
  echo "No existing bat installation found. Installing latest version..."

  # Get latest release info from GitHub API
  echo "Fetching latest bat release information..."
  LATEST_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest |
                  grep "tag_name" |
                  cut -d '"' -f 4 |
                  sed 's/v//')

  if [ -z "$LATEST_VERSION" ]; then
    echo "Error: Could not determine the latest bat version."
    exit 1
  fi

  echo "Latest version available: v$LATEST_VERSION"
fi

# Detect system architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  DEB_FILE="bat_${LATEST_VERSION}_amd64.deb"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
  DEB_FILE="bat_${LATEST_VERSION}_arm64.deb"
elif [ "$ARCH" = "armv7l" ]; then
  DEB_FILE="bat_${LATEST_VERSION}_armhf.deb"
elif [ "$ARCH" = "i686" ]; then
  DEB_FILE="bat_${LATEST_VERSION}_i686.deb"
else
  echo "Error: Unsupported architecture: $ARCH"
  exit 1
fi

# Create temporary directory for download
TMP_DIR=$(mktemp -d)
echo "Downloading bat to $TMP_DIR..."

# Construct the download URL
DOWNLOAD_URL="https://github.com/sharkdp/bat/releases/download/v${LATEST_VERSION}/${DEB_FILE}"

# Download the .deb file
wget -q -O "$TMP_DIR/$DEB_FILE" "$DOWNLOAD_URL"
if [ $? -ne 0 ]; then
  echo "Error: Download failed."
  rm -rf "$TMP_DIR"
  exit 1
fi

# Install the .deb package
echo "Installing bat..."
sudo dpkg -i "$TMP_DIR/$DEB_FILE"
if [ $? -ne 0 ]; then
  echo "Error: Installation failed. Attempting to resolve dependencies..."
  sudo apt-get -f install -y

  # Try installing again
  sudo dpkg -i "$TMP_DIR/$DEB_FILE"
  if [ $? -ne 0 ]; then
    echo "Error: Installation failed even after resolving dependencies."
    rm -rf "$TMP_DIR"
    exit 1
  fi
fi

# Clean up
rm -rf "$TMP_DIR"

# Verify installation
echo "Verifying installation..."
if command -v bat &> /dev/null; then
  NEW_VERSION=$(bat --version)
  echo "✓ bat installed successfully: $NEW_VERSION"
else
  echo "Error: bat installation verification failed."
  exit 1
fi
