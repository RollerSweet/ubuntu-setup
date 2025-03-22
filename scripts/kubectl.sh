#!/bin/bash
# kubectl

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

# Get the latest stable version
echo "Checking for latest kubectl version..."
LATEST_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

if [ -z "$LATEST_VERSION" ]; then
  echo "Error: Could not determine the latest kubectl version."
  exit 1
fi

echo "Latest version available: $LATEST_VERSION"

# Check if kubectl is already installed
if command -v kubectl &> /dev/null; then
  # Get current version
  CURRENT_VERSION=$(kubectl version --client | grep -o "Client Version: v[0-9.]*" | cut -d ' ' -f3)

  echo "Current version: $CURRENT_VERSION"

  # Compare versions
  if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "Latest version $LATEST_VERSION already installed."
    exit 0
  else
    if [ "$AUTO_YES" = false ]; then
      read -p "Update kubectl from $CURRENT_VERSION to $LATEST_VERSION? (y/n): " choice
      case "$choice" in
        y|Y ) ;;
        * ) echo "Update cancelled."; exit 0;;
      esac
    else
      echo "Auto-yes flag detected. Proceeding with update..."
    fi

    echo "Updating kubectl..."
  fi
else
  echo "kubectl not found. Installing version $LATEST_VERSION..."
fi

# Create temporary directory for download
TMP_DIR=$(mktemp -d)
echo "Downloading kubectl to $TMP_DIR..."

# Download kubectl binary
curl -LO "https://dl.k8s.io/release/$LATEST_VERSION/bin/linux/amd64/kubectl" -o "$TMP_DIR/kubectl"
if [ $? -ne 0 ]; then
  echo "Error: Download failed."
  rm -rf "$TMP_DIR"
  exit 1
fi

# Install kubectl
echo "Installing kubectl..."
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
if [ $? -ne 0 ]; then
  echo "Error: Installation failed."
  rm -rf "$TMP_DIR"
  exit 1
fi

# Clean up
rm -f kubectl

# Verify installation
echo "Verifying installation..."
if command -v kubectl &> /dev/null; then
  NEW_VERSION=$(kubectl version --client | grep -o "Client Version: v[0-9.]*" | cut -d ' ' -f3)
  echo "✓ kubectl installed successfully: $NEW_VERSION"
else
  echo "Error: kubectl installation verification failed."
  exit 1
fi

echo "Installation complete!"
exit 0

