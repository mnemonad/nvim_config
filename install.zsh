#!/bin/zsh
set -euo pipefail

# Check for Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Please install it from https://brew.sh/ and run again."
    exit 1
fi

echo "Updating Homebrew..."
brew update
brew upgrade

echo "Installing required packages..."
brew install git curl wget neovim lua luarocks

# Define directories
SRC="$(pwd)/config_src"
TARGET="$HOME/.config/nvim"

# Ensure the config_src directory is owned by the current user (adjust group as needed)
sudo chown -R "$(whoami):staff" "$SRC"

# Backup or remove existing Neovim config if needed
if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
    mv "$TARGET" "${TARGET}.bak.$(date +%Y%m%d%H%M%S)"
elif [ -L "$TARGET" ]; then
    rm "$TARGET"
fi

mkdir -p "$(dirname "$TARGET")"
ln -s "$SRC" "$TARGET"

echo "Neovim config setup complete."

