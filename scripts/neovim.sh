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

# Check if Neovim is already installed
if command -v nvim &> /dev/null; then
  CURRENT_VERSION=$(nvim --version | head -n 1)
  CURRENT_VERSION_NUM=$(echo "$CURRENT_VERSION" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+")

  # Get latest release info from GitHub API without output
  LATEST_URL=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest |
             grep "browser_download_url.*nvim-linux-x86_64.tar.gz\"" |
             grep -v "sha256sum" |
             cut -d '"' -f 4)

  if [ -z "$LATEST_URL" ]; then
    echo "Error: Could not determine the latest Neovim download URL."
    exit 1
  fi

  LATEST_VERSION=$(echo "$LATEST_URL" | grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+")
  LATEST_VERSION_NUM=$(echo "$LATEST_VERSION" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+")

  # Compare versions
  if [ "$CURRENT_VERSION_NUM" = "$LATEST_VERSION_NUM" ]; then
    echo "Latest version $LATEST_VERSION already installed."
    exit 0
  fi

  if [ "$AUTO_YES" = false ]; then
    read -p "Do you want to replace $CURRENT_VERSION with $LATEST_VERSION? (y/n): " choice
    case "$choice" in
      y|Y ) echo "Proceeding with installation...";;
      * ) echo "Installation cancelled."; exit 0;;
    esac
  else
    echo "Auto-yes flag detected. Proceeding with installation..."
  fi
else
  echo "No existing Neovim installation found. Installing latest version..."
fi

# If we haven't fetched the latest URL yet (in the case of no existing installation)
if [ -z "$LATEST_URL" ]; then
  # Get latest release info from GitHub API
  echo "Fetching latest Neovim release information..."
  LATEST_URL=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest |
               grep "browser_download_url.*nvim-linux-x86_64.tar.gz\"" |
               grep -v "sha256sum" |
               cut -d '"' -f 4)

  if [ -z "$LATEST_URL" ]; then
    echo "Error: Could not determine the latest Neovim download URL."
    exit 1
  fi

  LATEST_VERSION=$(echo "$LATEST_URL" | grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+")
  echo "Latest version available: $LATEST_VERSION"
fi

# Create temporary directory for download
TMP_DIR=$(mktemp -d)
echo "Downloading Neovim to $TMP_DIR..."

# Download tarball
wget -q -O "$TMP_DIR/nvim.tar.gz" "$LATEST_URL"
if [ $? -ne 0 ]; then
  echo "Error: Download failed."
  rm -rf "$TMP_DIR"
  exit 1
fi

# Extract tarball
echo "Extracting Neovim..."
tar xzf "$TMP_DIR/nvim.tar.gz" -C "$TMP_DIR"
if [ $? -ne 0 ]; then
  echo "Error: Extraction failed."
  rm -rf "$TMP_DIR"
  exit 1
fi

# Check if directory exists and remove it if needed
NVIM_DIR="/usr/local/nvim-linux-x86_64"
NVIM_DIR2="/usr/local/bin/nvim"
if [ -d "$NVIM_DIR" ]; then
  echo "Removing existing Neovim directory..."
  sudo rm -rf "$NVIM_DIR" && sudo rm -rf "$NVIM_DIR2"
fi

# Install Neovim
echo "Installing Neovim to /usr/local..."
sudo mv "$TMP_DIR/nvim-linux-x86_64" "/usr/local/"
if [ $? -ne 0 ]; then
  echo "Error: Failed to move Neovim to /usr/local."
  rm -rf "$TMP_DIR"
  exit 1
fi

# Create symbolic link
echo "Creating symbolic link..."
sudo ln -sf "/usr/local/nvim-linux-x86_64/bin/nvim" "/usr/local/bin/nvim"
if [ $? -ne 0 ]; then
  echo "Error: Failed to create symbolic link."
  exit 1
fi

# Clean up
rm -rf "$TMP_DIR"

# Verify installation
echo "Verifying installation..."
if command -v nvim &> /dev/null; then
  NEW_VERSION=$(nvim --version | head -n 1)
  echo "✓ Neovim installed successfully: $NEW_VERSION"
else
  echo "Error: Neovim installation verification failed."
  exit 1
fi

echo "Installation complete!"
