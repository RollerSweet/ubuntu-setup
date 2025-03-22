sudo apt-get update && sudo apt-get upgrade -yqq
sudo apt-get install -yqq golang

# Scripts
bash ./scripts/fonts.sh
bash ./scripts/ghostty.sh
bash ./scripts/alacritty.sh
bash ./scripts/bat.sh
bash ./scripts/neovim.sh
bash ./scripts/lazygit.sh
bash ./scripts/lazydocker.sh
bash ./scripts/kubectl.sh
bash ./scripts/fzf.sh

# Configs
mkdir -p ~/.config/{tmux,nvim}
cp ./configs/tmux/tmux.conf ~/.config/tmux/tmux.conf
cp -r ./nvim/* ~/.config/nvim
tmux source-file ~/.config/tmux/tmux.conf

