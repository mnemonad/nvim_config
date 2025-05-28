#!/bin/zsh
# install.zsh - Installation script for macOS
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

detect_system() {
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script is for macOS only. Use install.sh for Linux."
        exit 1
    fi
    
    MACOS_VERSION=$(sw_vers -productVersion)
    ARCH=$(uname -m)
    
    log_info "Detected macOS $MACOS_VERSION on $ARCH"
    
    if [[ $(echo "$MACOS_VERSION" | cut -d. -f1) -lt 10 ]] || 
       [[ $(echo "$MACOS_VERSION" | cut -d. -f1) -eq 10 && $(echo "$MACOS_VERSION" | cut -d. -f2) -lt 15 ]]; then
        log_error "macOS 10.15 (Catalina) or later is required"
        exit 1
    fi
}

install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        log_info "Homebrew not found, installing..."
        
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [[ "$ARCH" == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        log_success "Homebrew installed successfully"
    else
        log_info "Homebrew found: $(brew --version | head -n1)"
    fi
}

install_packages() {
    log_info "Updating Homebrew..."
    brew update
    
    read -q "REPLY?Upgrade existing Homebrew packages? (y/n): "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Upgrading Homebrew packages..."
        brew upgrade
    fi
    
    log_info "Installing required packages..."
    
    PACKAGES=(
        git
        curl
        wget
        neovim
        lua
        luarocks
        ripgrep
        fd
        fzf
        tree
        jq 
    )
    
    OPTIONAL_PACKAGES=(
        tmux 
        htop
        bat 
        exa
        delta
        lazygit
    )
    
    for package in "${PACKAGES[@]}"; do
        if brew list "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        else
            log_info "Installing $package..."
            brew install "$package"
        fi
    done
    
    read -q "REPLY?Install optional development tools (tmux, htop, bat, etc.)? (y/n): "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for package in "${OPTIONAL_PACKAGES[@]}"; do
            if brew list "$package" >/dev/null 2>&1; then
                log_info "$package already installed"
            else
                log_info "Installing $package..."
                brew install "$package" || log_warning "Failed to install $package"
            fi
        done
    fi
}

install_fonts() {
    log_info "Installing Nerd Fonts for better terminal experience..."
    
    brew tap homebrew/cask-fonts 2>/dev/null || true
    
    FONTS=(
        font-fira-code-nerd-font
        font-jetbrains-mono-nerd-font
        font-hack-nerd-font
    )
    
    read -q "REPLY?Install Nerd Fonts for better terminal icons? (y/n): "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for font in "${FONTS[@]}"; do
            if brew list --cask "$font" >/dev/null 2>&1; then
                log_info "$font already installed"
            else
                log_info "Installing $font..."
                brew install --cask "$font" || log_warning "Failed to install $font"
            fi
        done
        log_info "Fonts installed. You may need to restart your terminal and select a Nerd Font."
    fi
}

setup_nvim_config() {
    log_info "Setting up Neovim configuration..."
    
    SRC="$(pwd)/config_src"
    TARGET="$HOME/.config/nvim"
    
    if [[ ! -d "$SRC" ]]; then
        log_error "Source directory $SRC does not exist"
        log_info "Make sure you're running this script from the project root directory"
        exit 1
    fi
    
    if [[ "$(stat -f '%Su' "$SRC")" != "$(whoami)" ]]; then
        log_info "Fixing ownership of source directory..."
        chown -R "$(whoami):staff" "$SRC"
    fi
    
    if [[ -e "$TARGET" && ! -L "$TARGET" ]]; then
        BACKUP="${TARGET}.bak.$(date +%Y%m%d%H%M%S)"
        log_info "Backing up existing config to $BACKUP"
        mv "$TARGET" "$BACKUP"
    elif [[ -L "$TARGET" ]]; then
        log_info "Removing existing symbolic link"
        rm "$TARGET"
    fi
    
    mkdir -p "$(dirname "$TARGET")"
    ln -sf "$SRC" "$TARGET"
    
    log_success "Neovim config linked successfully"
}

setup_zsh_config() {
    log_info "Setting up Zsh configuration..."
    
    touch "$HOME/.zshrc"
    
    ALIAS_SECTION="# Neovim IDE aliases"
    ALIASES=(
        "alias vim='nvim'"
        "alias vi='nvim'"
        "alias oldvim='$(which vim 2>/dev/null || echo /usr/bin/vim)'"
    )
    
    if ! grep -q "$ALIAS_SECTION" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "$ALIAS_SECTION" >> "$HOME/.zshrc"
        
        for alias_cmd in "${ALIASES[@]}"; do
            echo "$alias_cmd" >> "$HOME/.zshrc"
        done
        
        log_success "Added Neovim aliases to .zshrc"
    else
        log_info "Neovim aliases already configured"
    fi
    
    ENV_SECTION="# Neovim IDE environment"
    ENV_VARS=(
        "export EDITOR='nvim'"
        "export VISUAL='nvim'"
    )
    
    if ! grep -q "$ENV_SECTION" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "$ENV_SECTION" >> "$HOME/.zshrc"
        
        for env_var in "${ENV_VARS[@]}"; do
            echo "$env_var" >> "$HOME/.zshrc"
        done
        
        log_success "Added environment variables to .zshrc"
    fi
    
    if command -v fzf >/dev/null 2>&1; then
        if [[ ! -f "$HOME/.fzf.zsh" ]]; then
            log_info "Setting up FZF integration..."
            $(brew --prefix)/opt/fzf/install --key-bindings --completion --update-rc
        fi
    fi
}

install_macos_tools() {
    log_info "Installing macOS-specific development tools..."
    
    if ! xcode-select -p >/dev/null 2>&1; then
        log_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        read -p "Press enter after Xcode Command Line Tools installation completes..."
    else
        log_info "Xcode Command Line Tools already installed"
    fi
    
    MACOS_PACKAGES=(
        mas
        mackup
        duti
    )
    
    read -q "REPLY?Install additional macOS tools (mas, mackup, duti)? (y/n): "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for package in "${MACOS_PACKAGES[@]}"; do
            if brew list "$package" >/dev/null 2>&1; then
                log_info "$package already installed"
            else
                log_info "Installing $package..."
                brew install "$package" || log_warning "Failed to install $package"
            fi
        done
    fi
}

setup_iterm2() {
    if [[ -d "/Applications/iTerm.app" ]]; then
        log_info "iTerm2 detected, setting up shell integration..."
        
        curl -L https://iterm2.com/shell_integration/zsh -o "$HOME/.iterm2_shell_integration.zsh"
        
        ITERM_LINE='source ~/.iterm2_shell_integration.zsh'
        if ! grep -q "$ITERM_LINE" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# iTerm2 shell integration" >> "$HOME/.zshrc"
            echo "$ITERM_LINE" >> "$HOME/.zshrc"
            log_success "iTerm2 shell integration configured"
        fi
    fi
}

setup_dev_environment() {
    log_info "Setting up development environment..."
    
    DEV_DIRS=(
        "$HOME/Developer"
        "$HOME/Projects"
        "$HOME/.local/bin"
    )
    
    for dir in "${DEV_DIRS[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Created directory: $dir"
        fi
    done
    
    if [[ ! "$PATH" == *"$HOME/.local/bin"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
        log_info "Added ~/.local/bin to PATH"
    fi
}

health_check() {
    log_info "Running health check..."
    
    ISSUES=0
    
    if command -v nvim >/dev/null 2>&1; then
        NVIM_VERSION=$(nvim --version | head -n1)
        log_success "Neovim: $NVIM_VERSION"
    else
        log_error "Neovim not found"
        ((ISSUES++))
    fi
    
    if command -v git >/dev/null 2>&1; then
        log_success "Git: $(git --version)"
    else
        log_error "Git not found"
        ((ISSUES++))
    fi
    
    if [[ -L "$HOME/.config/nvim" ]]; then
        log_success "Neovim config symlink: ✅"
    else
        log_error "Neovim config symlink not found"
        ((ISSUES++))
    fi
    
    if command -v brew >/dev/null 2>&1; then
        log_success "Homebrew: $(brew --version | head -n1)"
    else
        log_warning "Homebrew not found"
    fi
    
    OPTIONAL_TOOLS=(ripgrep fd fzf)
    for tool in "${OPTIONAL_TOOLS[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            log_success "$tool: ✅"
        else
            log_info "$tool: not installed (optional)"
        fi
    done
    
    if [[ $ISSUES -eq 0 ]]; then
        log_success "All essential checks passed! 🎉"
        log_info "Please restart your terminal or run: source ~/.zshrc"
        log_info "Your portable IDE is ready to use!"
    else
        log_error "$ISSUES critical issues found. Please review the output above."
        exit 1
    fi
}

main() {
    log_info "Starting Neovim Portable IDE setup for macOS..."
    
    detect_system
    install_homebrew
    install_packages
    install_fonts
    install_macos_tools
    setup_nvim_config
    setup_zsh_config
    setup_iterm2
    setup_dev_environment
    health_check
    
    log_success "Installation complete! 🚀"
    log_info ""
    log_info "Next steps:"
    log_info "1. Restart your terminal"
    log_info "2. Run 'vim' or 'nvim' to start your IDE"
    log_info "3. The first run will install plugins automatically"
    log_info "4. Consider setting a Nerd Font in your terminal for better icons"
}

trap 'log_error "Installation interrupted"; exit 1' INT

main "$@"
