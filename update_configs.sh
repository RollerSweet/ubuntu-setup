#!/bin/bash

# Define colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define source and destination directories
SOURCE_DIR="$HOME/.config"
DEST_DIR="./configs"

# Array of config directories to backup
CONFIG_DIRS=(
    "tmux/tmux.conf"
    "alacritty/alacritty.toml"
    "nvim"
)

# Create function to backup a config
backup_config() {
    local source="$SOURCE_DIR/$1"
    local dest="$DEST_DIR/$1"
    local dest_dir=$(dirname "$dest")

    # Check if source exists
    if [ ! -e "$source" ]; then
        echo -e "${RED}Error: Source '$source' does not exist.${NC}"
        return 1
    fi

    # Create destination directory if it doesn't exist
    if [ ! -d "$dest_dir" ]; then
        mkdir -p "$dest_dir"
        echo -e "${YELLOW}Created directory: $dest_dir${NC}"
    fi

    # Backup the config
    if [ -d "$source" ]; then
        # For directories (like nvim), copy the contents
        cp -rf "$source"/* "$dest_dir"/
        echo -e "${GREEN}Backed up directory: $source → $dest_dir${NC}"
    else
        # For files (like tmux.conf), copy the file
        cp -f "$source" "$dest"
        echo -e "${GREEN}Backed up file: $source → $dest${NC}"
    fi
}

# Main execution
echo -e "${YELLOW}Starting configuration backup...${NC}"

for config in "${CONFIG_DIRS[@]}"; do
    backup_config "$config"
done

echo -e "${GREEN}Backup completed successfully!${NC}"
