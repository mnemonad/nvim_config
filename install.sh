#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Update and upgrade system packages
sudo apt-get update && sudo apt-get upgrade -y

# Install required packages
sudo apt install -y git curl wget build-essential software-properties-common lua5.4 luarocks

# Add Neovim PPA and install Neovim
sudo add-apt-repository ppa:neovim-ppa/stable -y
sudo apt-get update
sudo apt-get install -y neovim

# Setup Neovim config
SRC="$(pwd)/config_src"
TARGET="$HOME/.config/nvim"

sudo chown -R "$(whoami):$(whoami)" "$SRC"

if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
    mv "$TARGET" "${TARGET}.bak.$(date +%Y%m%d%H%M%S)"
elif [ -L "$TARGET" ]; then
    rm "$TARGET"
fi

mkdir -p "$(dirname "$TARGET")"
ln -s "$SRC" "$TARGET"
echo "Neovim config setup complete."

# Set aliases: make vim call nvim and, if a native vim exists, alias it as rvim.
ALIAS_FILE="$HOME/.bash_aliases"
touch "$ALIAS_FILE"

# Append alias vim=nvim if not already present
if ! grep -q "^alias vim='nvim'" "$ALIAS_FILE"; then
    echo "alias vim='nvim'" >> "$ALIAS_FILE"
    echo "Added alias: vim -> nvim"
fi

# Capture the native vim (if any) before the alias takes effect in interactive shells.
native_vim=$(command -v vim 2>/dev/null || echo "")
nvim_path=$(command -v nvim)

if [ -n "$native_vim" ] && [ "$native_vim" != "$nvim_path" ]; then
    if ! grep -q "^alias rvim=" "$ALIAS_FILE"; then
        echo "alias rvim='$native_vim'" >> "$ALIAS_FILE"
        echo "Added alias: rvim -> $native_vim"
    fi
fi

echo "Alias setup complete. Please restart your terminal or run 'source $ALIAS_FILE' to apply the changes."

