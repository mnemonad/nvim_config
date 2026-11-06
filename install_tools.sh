#!/usr/bin/env bash
# Sets up this editor for the current user: the same Neovim, tools, plugins and
# language servers on every machine. No sudo. Ubuntu only, amd64 or arm64.
# Safe to run again, and again after pulling this repo.
#
#   ~/.local/opt/nvim-v<version>           Neovim
#   ~/.local/share/beam/otp-<version>      Erlang
#   ~/.local/share/beam/elixir-<version>   Elixir, including its source
#   ~/.local/bin                           links to all of them
#   ~/.config/nvim                         link to this repo's config_src
#
# Erlang and Elixir stay the same as images/versions.env in Pharos, so the
# editor reads the code with the Elixir that runs it. Installing a new Neovim
# leaves the old one in ~/.local/opt, so going back is one symlink.
set -euo pipefail

NVIM_VERSION=0.12.6
TREE_SITTER_VERSION=0.27.1
OTP_VERSION=28.5.0.8
ELIXIR_VERSION=1.20.4
OTP_MAJOR=${OTP_VERSION%%.*}

MASON_PACKAGES="lua-language-server rust-analyzer pyright bash-language-server yaml-language-server marksman buf elixir-ls"

. /etc/os-release
if [ "${ID:-}" != "ubuntu" ]; then
  echo "install_tools: skipping, this script only knows Ubuntu, not ${ID:-this OS}" >&2
  exit 0
fi

arch=$(dpkg --print-architecture)
case "$arch" in
  amd64) nvim_arch=x86_64; tree_sitter_arch=x64 ;;
  arm64) nvim_arch=arm64; tree_sitter_arch=arm64 ;;
  *) echo "install_tools: no builds for $arch" >&2; exit 1 ;;
esac

repo="$(cd "$(dirname "$0")" && pwd)"
bin="$HOME/.local/bin"
opt="$HOME/.local/opt"
beam="$HOME/.local/share/beam"
mkdir -p "$bin" "$opt" "$beam" "$HOME/.config"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fetch() { curl -fsSL --limit-rate 10M -o "$2" "$1"; }

# Link the config before anything starts Neovim. A real folder may hold someone's
# work, so stop rather than replace it. A symlink only points at a clone, which stays.
if [ -e "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
  echo "install_tools: ~/.config/nvim is a real folder; move it aside first" >&2
  exit 1
fi
ln -sfn "$repo/config_src" "$HOME/.config/nvim"

nvim_dir="$opt/nvim-v$NVIM_VERSION"
if [ ! -x "$nvim_dir/bin/nvim" ]; then
  fetch "https://github.com/neovim/neovim/releases/download/v$NVIM_VERSION/nvim-linux-$nvim_arch.tar.gz" "$tmp/nvim.tar.gz"
  rm -rf "$nvim_dir"
  mkdir -p "$nvim_dir"
  tar xzf "$tmp/nvim.tar.gz" -C "$nvim_dir" --strip-components=1
fi
ln -sfn "$nvim_dir/bin/nvim" "$bin/nvim"

tree_sitter="$opt/tree-sitter-v$TREE_SITTER_VERSION"
if [ ! -x "$tree_sitter" ]; then
  fetch "https://github.com/tree-sitter/tree-sitter/releases/download/v$TREE_SITTER_VERSION/tree-sitter-linux-$tree_sitter_arch.gz" "$tmp/tree-sitter.gz"
  gunzip -c "$tmp/tree-sitter.gz" > "$tree_sitter"
  chmod +x "$tree_sitter"
fi
ln -sfn "$tree_sitter" "$bin/tree-sitter"

otp="$beam/otp-$OTP_VERSION"
if [ ! -x "$otp/bin/erl" ]; then
  fetch "https://builds.hex.pm/builds/otp/$arch/ubuntu-$VERSION_ID/OTP-$OTP_VERSION.tar.gz" "$tmp/otp.tar.gz"
  rm -rf "$otp"
  mkdir -p "$otp"
  tar xzf "$tmp/otp.tar.gz" -C "$otp" --strip-components=1
  "$otp/Install" -minimal "$otp" >/dev/null
fi

elixir="$beam/elixir-$ELIXIR_VERSION"
if [ ! -x "$elixir/bin/elixir" ]; then
  fetch "https://builds.hex.pm/builds/elixir/v$ELIXIR_VERSION-otp-$OTP_MAJOR.zip" "$tmp/elixir.zip"
  rm -rf "$elixir"
  mkdir -p "$elixir"
  python3 -m zipfile -e "$tmp/elixir.zip" "$elixir"
  chmod +x "$elixir"/bin/*
fi

for tool in elixir elixirc iex mix; do ln -sfn "$elixir/bin/$tool" "$bin/$tool"; done
for tool in erl erlc escript; do ln -sfn "$otp/bin/$tool" "$bin/$tool"; done

export PATH="$bin:$PATH"
mix local.hex --force --if-missing >/dev/null
mix local.rebar --force --if-missing >/dev/null

# Plugins at the commits in lazy-lock.json.
nvim --headless "+Lazy! install" "+Lazy! restore" +qa

# Parsers, which treesitter otherwise installs in the background on first start.
nvim --headless -c "lua require('nvim-treesitter').install(vim.g.treesitter_parsers):wait(300000)" -c qa

# Language servers. Mason skips ensure_installed in a headless Neovim.
missing=""
for package in $MASON_PACKAGES; do
  [ -d "$HOME/.local/share/nvim/mason/packages/$package" ] || missing="$missing $package"
done
if [ -n "$missing" ]; then
  # shellcheck disable=SC2086
  nvim --headless -c "MasonInstall$missing" -c qa
fi

# mason's elixir-ls compiles the real server on first start. Do it now, not on first jump.
echo "" | MIX_ENV=prod elixir "$HOME/.local/share/nvim/mason/packages/elixir-ls/quiet_install.exs" >/dev/null

echo
echo "install_tools: done"
nvim --version | head -1
tree-sitter --version
elixir --version | tail -1
echo "treesitter parsers: $(ls "$HOME/.local/share/nvim/site/parser" 2>/dev/null | wc -l)"
command -v cc >/dev/null || echo "WARNING: no C compiler (cc), so treesitter can't build parsers. Install build-essential."
if ! bash -lc 'command -v nvim' >/dev/null 2>&1; then
  echo "WARNING: ~/.local/bin isn't on PATH in a login shell. Add it to your shell's profile."
fi
