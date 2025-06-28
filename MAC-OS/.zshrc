# =============================================================================
# POWERLEVEL10K INSTANT PROMPT
# =============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# OH-MY-ZSH CONFIGURATION
# =============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git terraform)
source $ZSH/oh-my-zsh.sh

# =============================================================================
# PATH CONFIGURATION
# =============================================================================
export PATH="$HOME/.local/bin:$PATH"

# =============================================================================
# THEME CONFIGURATION
# =============================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================================
# TOOL INTEGRATION
# =============================================================================
# FZF (Fuzzy Finder)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# =============================================================================
# KUBERNETES CONFIGURATION
# =============================================================================
# Enable kubectl autocompletion
source ~/.kubectl_completion
export KUBECONFIG=$HOME/.kube/config

# Helm completion
source <(helm completion zsh)
source <(velero completion zsh)
# =============================================================================
# NVM (NODE VERSION MANAGER)
# =============================================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# =============================================================================
# ALIASES
# =============================================================================
# Vim
alias vim=nvim

# Kubernetes
alias k=kubectl
compdef __start_kubectl k

# Cursor (Editor)

# Cursor Setup Wizard
export PATH=$PATH:$(go env GOPATH)/bin


autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /home/tamir.m/.tfenv/versions/1.9.5/terraform terraform

# bun completions
[ -s "/home/tamir.m/.bun/_bun" ] && source "/home/tamir.m/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

complete -o nospace -C /usr/bin/hcp hcp

# Enable Argo CD autocompletion
autoload -U compinit
compinit

# Load Argo CD completions inline
source <(argocd completion zsh)

# pnpm
export PNPM_HOME="/home/tamir.m/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
