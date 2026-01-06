# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme - using custom theme with conda support
ZSH_THEME="portable-dev"

# Plugins
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Editor
export EDITOR='nvim'

# Aliases
alias vim="nvim"
alias rvim="vim"
alias rtree='tree'
alias tree='tree --dirsfirst -I "__pycache__|*.egg-info|*.pyc|*.log|.git|venv|dist|__init__.py|pyproject.toml|node_modules|package-lock.json|.svelte-kit|build|target"'

# Disable conda from modifying the prompt (we handle it in theme)
export CONDA_CHANGEPS1=false

# >>> conda initialize >>>
# Portable conda setup - checks common locations
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
elif [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/anaconda3/etc/profile.d/conda.sh"
elif [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
    . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
fi
# <<< conda initialize <<<

# Cargo/Rust
export CARGO_HOME="$HOME/.cargo"
[ -f "$CARGO_HOME/env" ] && . "$CARGO_HOME/env"

# NVM/Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Local bin
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
