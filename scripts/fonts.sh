#!/bin/bash
wget -4q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip
unzip -oq JetBrainsMono.zip -d ~/.fonts
rm -f JetBrainsMono.zip
fc-cache -f 2>/dev/null
FONT_COUNT=$(find ~/.fonts -name "JetBrainsMono*.ttf" | wc -l)
echo "Fonts: $FONT_COUNT installed"
