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

# Check if zsh is installed
if command -v zsh &> /dev/null; then
  CURRENT_ZSH_VERSION=$(zsh --version | cut -d ' ' -f2)

  # Get the current installed version and available version in full format
  CURRENT_ZSH_FULL=$(apt-cache policy zsh | grep Installed | awk '{print $2}')
  AVAILABLE_ZSH_FULL=$(apt-cache policy zsh | grep Candidate | awk '{print $2}')

  # Compare versions using Debian version comparison
  if [ "$CURRENT_ZSH_FULL" != "$AVAILABLE_ZSH_FULL" ]; then
    echo "A different version of zsh is available: $AVAILABLE_ZSH_FULL"

    if [ "$AUTO_YES" = false ]; then
      read -p "Update zsh to version $AVAILABLE_ZSH_VERSION? (y/n): " choice
      case "$choice" in
        y|Y ) ;;
        * ) echo "zsh update cancelled."; ;;
      esac
    fi

    if [ "$AUTO_YES" = true ] || [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
      echo "Updating zsh..."
      sudo apt-get install --only-upgrade zsh -y
      if [ $? -ne 0 ]; then
        echo "Error: Failed to update zsh."
      else
        echo "✓ zsh updated successfully to $(zsh --version | cut -d ' ' -f2)"
      fi
    fi
  else
    echo "zsh is already at the latest version ($CURRENT_ZSH_FULL)"
  fi
else
  echo "zsh is not installed. Installing..."
  sudo apt-get update -qq > /dev/null
  sudo apt-get install zsh -y

  if [ $? -ne 0 ]; then
    echo "Error: Failed to install zsh."
    exit 1
  else
    echo "✓ zsh installed successfully: $(zsh --version | cut -d ' ' -f2)"
  fi
fi

# Check if Oh My Zsh is installed
if [ -d "$HOME/.oh-my-zsh" ]; then
  # Check for Oh My Zsh updates
  if [ -d "$HOME/.oh-my-zsh/.git" ]; then
    cd "$HOME/.oh-my-zsh"

    # Fetch latest changes without applying them
    git fetch > /dev/null 2>&1

    # Check if local is behind remote
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "@{u}")

    if [ "$LOCAL" != "$REMOTE" ]; then
      # Get current commit info
      CURRENT_COMMIT=$(git rev-parse --short HEAD)
      CURRENT_DATE=$(git log -1 --format=%cd --date=short HEAD)

      # Get remote commit info
      REMOTE_COMMIT=$(git rev-parse --short "@{u}")
      REMOTE_DATE=$(git log -1 --format=%cd --date=short "@{u}")

      echo "A newer version of Oh My Zsh is available."
      echo "Current version: $CURRENT_COMMIT (from $CURRENT_DATE)"
      echo "New version: $REMOTE_COMMIT (from $REMOTE_DATE)"

      # Get commit count difference
      COMMIT_DIFF=$(git rev-list --count "$LOCAL".."$REMOTE")
      echo "Updates available: $COMMIT_DIFF commits"

      if [ "$AUTO_YES" = false ]; then
        read -p "Update Oh My Zsh? (y/n): " choice
        case "$choice" in
          y|Y ) ;;
          * ) echo "Oh My Zsh update cancelled."; ;;
        esac
      fi

      if [ "$AUTO_YES" = true ] || [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        echo "Updating Oh My Zsh..."
        # Use git pull instead of upgrade_oh_my_zsh which is only available in zsh sessions
        cd "$HOME/.oh-my-zsh"
        git pull
        if [ $? -ne 0 ]; then
          echo "Error: Failed to update Oh My Zsh."
          echo "You can try updating manually with: cd ~/.oh-my-zsh && git pull"
        else
          echo "✓ Oh My Zsh updated successfully."
        fi
        cd - > /dev/null
      fi
    else
      # Get current version info
      CURRENT_COMMIT=$(git rev-parse --short HEAD)
      CURRENT_DATE=$(git log -1 --format=%cd --date=short HEAD)
      echo "Oh My Zsh is already at the latest version ($CURRENT_COMMIT from $CURRENT_DATE)"
    fi

    cd - > /dev/null
  else
    echo "Oh My Zsh git repository not found. Cannot check for updates."
  fi
else
  echo "Oh My Zsh is not installed. Installing..."

  if [ "$AUTO_YES" = false ]; then
    read -p "Install Oh My Zsh? (y/n): " choice
    case "$choice" in
      y|Y ) ;;
      * ) echo "Oh My Zsh installation cancelled."; exit 0;;
    esac
  fi

  # Install Oh My Zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  if [ $? -ne 0 ]; then
    echo "Error: Failed to install Oh My Zsh."
    exit 1
  else
    echo "✓ Oh My Zsh installed successfully."
    echo "Note: Oh My Zsh has been installed but not activated."
    echo "To use zsh as your default shell, run: chsh -s $(which zsh)"
  fi
fi

exit 0
