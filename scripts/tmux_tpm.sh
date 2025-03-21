#!/bin/bash

# Install tmux
apt-get install tmux -yqq

# Create config directory if it doesn't exist
mkdir -p ~/.config/tmux/plugins

# Clone TPM if it doesn't exist
if [ ! -d ~/.config/tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi

# Create or check tmux.conf
TMUX_CONF=~/.config/tmux/tmux.conf
touch "$TMUX_CONF"

# Check if tpm plugin line exists, if not add it
if ! grep -q "set -g @plugin 'tmux-plugins/tpm'" "$TMUX_CONF"; then
    echo "set -g @plugin 'tmux-plugins/tpm'" >> "$TMUX_CONF"
fi

# Check if tmux-sensible plugin line exists, if not add it
if ! grep -q "set -g @plugin 'tmux-plugins/tmux-sensible'" "$TMUX_CONF"; then
    echo "set -g @plugin 'tmux-plugins/tmux-sensible'" >> "$TMUX_CONF"
fi

# Check if tpm initialization line exists, if not add it
if ! grep -q "run '~/.config/tmux/plugins/tpm/tpm'" "$TMUX_CONF"; then
    echo "run '~/.config/tmux/plugins/tpm/tpm'" >> "$TMUX_CONF"
fi

# Source tmux.conf if tmux is running
if [ -n "$TMUX" ]; then
    echo "Reloading tmux configuration..."
    tmux source ~/.config/tmux/tmux.conf
    echo "Configuration reloaded. Press 'prefix + I' to install plugins."
else
    echo "tmux is not running. Start tmux and run 'tmux source ~/.config/tmux/tmux.conf' to load the configuration."
    echo "After loading, press 'prefix + I' to install plugins."
fi

echo "Setup complete!"
