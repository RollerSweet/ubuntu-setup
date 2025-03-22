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

# Check if Alacritty is already installed
if command -v alacritty &> /dev/null; then
  # Check if the PPA is added
  if ! grep -q "aslatter/ppa" /etc/apt/sources.list.d/* 2>/dev/null; then
    if [ "$AUTO_YES" = false ]; then
      read -p "Alacritty is installed but not from PPA. Add PPA for updates? (y/n): " choice
      case "$choice" in
        y|Y ) ;;
        * ) echo "Skipping PPA setup."; exit 0;;
      esac
    fi
    echo "Adding Alacritty PPA..."
    sudo add-apt-repository ppa:aslatter/ppa -y > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "Error: Failed to add Alacritty PPA."
      exit 1
    fi
  fi

  # Get current version
  CURRENT_VERSION=$(alacritty --version | awk '{print $2}')

  # Update package lists
  sudo apt-get update -qq > /dev/null 2>&1

  # Check available version in repository
  AVAILABLE_VERSION=$(apt-cache policy alacritty | grep Candidate | awk '{print $2}')

  if [ "$CURRENT_VERSION" = "$AVAILABLE_VERSION" ]; then
    echo "Latest version $CURRENT_VERSION already installed."
    exit 0
  else
    echo "Current version: $CURRENT_VERSION"
    echo "Available version: $AVAILABLE_VERSION"

    if [ "$AUTO_YES" = false ]; then
      read -p "Update Alacritty? (y/n): " choice
      case "$choice" in
        y|Y ) ;;
        * ) echo "Update cancelled."; exit 0;;
      esac
    fi

    echo "Updating Alacritty..."
    sudo apt-get install --only-upgrade alacritty -yqq > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "Error: Failed to update Alacritty."
      exit 1
    fi

    echo "✓ Alacritty updated successfully to $(alacritty --version | awk '{print $2}')"
  fi
else
  echo "Alacritty not found. Installing..."

  # Add PPA
  echo "Adding Alacritty PPA..."
  sudo add-apt-repository ppa:aslatter/ppa -y > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add Alacritty PPA."
    exit 1
  fi

  # Update package lists and install Alacritty
  echo "Installing Alacritty..."
  sudo apt-get update -qq > /dev/null 2>&1
  sudo apt-get install alacritty -yqq > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    echo "Error: Failed to install Alacritty."
    exit 1
  fi

  # Verify installation
  if command -v alacritty &> /dev/null; then
    echo "✓ Alacritty installed successfully: $(alacritty --version | awk '{print $2}')"
  else
    echo "Error: Alacritty installation verification failed."
    exit 1
  fi
fi

exit 0
