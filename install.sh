sudo apt-get update && sudo apt-get upgrade -yqq
sudo apt-get install -yqq golang

# Scripts
bash ./scripts/neovim.sh
bash ./scripts/fonts.sh

# Alacritty
sudo add-apt-repository ppa:aslatter/ppa -y
sudo apt-get install alacritty -yqq

# Ghostty
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"

# Lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

# Lazydocker
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash


# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Configs
mkdir -p ~/.config/{tmux,nvim}
cp ./configs/tmux/tmux.conf ~/.config/tmux/tmux.conf
cp -r ./nvim/* ~/.config/nvim
