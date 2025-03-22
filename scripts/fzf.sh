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

# Get the latest version from GitHub API
echo "Checking for latest fzf version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | jq -r .tag_name)

if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
  echo "Error: Could not determine the latest fzf version."
  exit 1
fi

echo "Latest version available: $LATEST_VERSION"

# Check if fzf is already installed
if command -v fzf &> /dev/null; then
  # Get current version and full version info
  CURRENT_VERSION=$(fzf --version | cut -d ' ' -f1)
  FULL_VERSION_INFO=$(fzf --version)

  echo "Current version: $CURRENT_VERSION"
  echo "Full version info: $FULL_VERSION_INFO"

  # Check if this is a package-managed version
  if [[ "$FULL_VERSION_INFO" == *"(debian)"* ]]; then
    echo "Detected Debian-packaged version of fzf."
    echo "Warning: Installing alongside the Debian package. You may need to uninstall the Debian package."
    sudo apt-get remove fzf -y
  fi

  # Compare versions (remove 'v' prefix if present for comparison)
  CURRENT_CLEAN=${CURRENT_VERSION#v}
  LATEST_CLEAN=${LATEST_VERSION#v}

  if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ] || [ "$CURRENT_CLEAN" = "$LATEST_CLEAN" ]; then
    echo "Latest version $LATEST_VERSION already installed."
    exit 0
  else
    if [ "$AUTO_YES" = false ]; then
      read -p "Update fzf from $CURRENT_VERSION to $LATEST_VERSION? (y/n): " choice
      case "$choice" in
        y|Y ) ;;
        * ) echo "Update cancelled."; exit 0;;
      esac
    else
      echo "Auto-yes flag detected. Proceeding with update..."
    fi

    echo "Updating fzf..."
  fi
else
  echo "fzf not found. Installing version $LATEST_VERSION..."
fi

# Create temporary directory for download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" || { echo "Error: Failed to create temporary directory."; exit 1; }

# Download fzf binary
echo "Downloading fzf $LATEST_VERSION..."
wget -q "https://github.com/junegunn/fzf/releases/download/${LATEST_VERSION}/fzf-${LATEST_VERSION#v}-linux_amd64.tar.gz"
if [ $? -ne 0 ]; then
  echo "Error: Download failed."
  cd - > /dev/null
  rm -rf "$TMP_DIR"
  exit 1
fi

# Extract the tarball
echo "Extracting fzf..."
tar -xzf "fzf-${LATEST_VERSION#v}-linux_amd64.tar.gz"
if [ $? -ne 0 ]; then
  echo "Error: Extraction failed."
  cd - > /dev/null
  rm -rf "$TMP_DIR"
  exit 1
fi

# Install fzf
echo "Installing fzf to /usr/local/bin/..."
sudo mv fzf /usr/local/bin/
if [ $? -ne 0 ]; then
  echo "Error: Installation failed."
  cd - > /dev/null
  rm -rf "$TMP_DIR"
  exit 1
fi

# Clean up
cd - > /dev/null
rm -rf "$TMP_DIR"

# Verify installation
echo "Verifying installation..."
if command -v fzf &> /dev/null; then
  NEW_VERSION=$(fzf --version | cut -d ' ' -f1)
  FULL_NEW_VERSION_INFO=$(fzf --version)

  if [[ "$FULL_NEW_VERSION_INFO" == *"(debian)"* ]]; then
    echo "Warning: System is still using the Debian-packaged version."
    echo "Checking /usr/local/bin/fzf directly..."
    if [ -f "/usr/local/bin/fzf" ]; then
      ACTUAL_NEW_VERSION=$(/usr/local/bin/fzf --version | cut -d ' ' -f1)
      echo "✓ fzf installed successfully to /usr/local/bin/: $ACTUAL_NEW_VERSION"
      echo "However, your PATH is prioritizing the Debian package version."
      echo "Consider removing the Debian package with: sudo apt-get remove fzf"
      echo "Or adjust your PATH to prioritize /usr/local/bin"
    else
      echo "Error: fzf was not properly installed to /usr/local/bin."
      exit 1
    fi
  else
    echo "✓ fzf installed successfully: $NEW_VERSION"
  fi
else
  echo "Error: fzf installation verification failed."
  exit 1
fi

echo "Installation complete!"
exit 0
