#!/bin/bash
# install.sh - Installation script for Linux systems
set -euo pipefail
IFS=$'\n\t'

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
        CODENAME=${VERSION_CODENAME:-}
    elif [[ -f /etc/redhat-release ]]; then
        OS="rhel"
        VER=$(grep -oE '[0-9]+' /etc/redhat-release | head -1)
    else
        log_error "Cannot detect OS. Supported: Ubuntu, Debian, CentOS, RHEL, Fedora"
        exit 1
    fi
    
    log_info "Detected OS: $OS $VER ${CODENAME:+($CODENAME)}"
}

check_sudo() {
    if [[ $EUID -eq 0 ]]; then
        log_warning "Running as root. This is not recommended."
        SUDO=""
    else
        SUDO="sudo"
    fi
}

install_packages() {
    log_info "Installing required packages..."
    
    case $OS in
        ubuntu|debian)
            $SUDO apt-get update
            
            PACKAGES="git curl wget build-essential software-properties-common"
            
            if [[ "$OS" == "debian" && "$VER" == "12" ]] || [[ "$CODENAME" == "bookworm" ]]; then
                log_info "Detected Debian 12 (Bookworm)"
                PACKAGES="$PACKAGES lua5.4 lua5.4-dev luarocks"
            elif [[ "$OS" == "ubuntu" && $(echo "$VER >= 22.04" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
                PACKAGES="$PACKAGES lua5.4 lua5.4-dev luarocks"
            else
                # Fallback for older versions
                PACKAGES="$PACKAGES lua5.3 lua5.3-dev luarocks"
            fi
            
            $SUDO apt-get install -y $PACKAGES
            
            install_neovim_debian_ubuntu
            ;;
            
        fedora)
            $SUDO dnf update -y
            $SUDO dnf install -y git curl wget gcc gcc-c++ make lua lua-devel luarocks neovim
            ;;
            
        centos|rhel)
            if [[ "$VER" -ge 8 ]]; then
                $SUDO dnf update -y
                $SUDO dnf install -y epel-release
                $SUDO dnf install -y git curl wget gcc gcc-c++ make lua lua-devel

                install_luarocks_from_source
                install_neovim_appimage
            else
                log_error "CentOS/RHEL 7 and below are not supported"
                exit 1
            fi
            ;;
            
        arch|manjaro)
            $SUDO pacman -Syu --noconfirm
            $SUDO pacman -S --noconfirm git curl wget base-devel lua luarocks neovim
            ;;
            
        *)
            log_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

install_neovim_debian_ubuntu() {
    if command -v snap >/dev/null 2>&1; then
        log_info "Installing Neovim via snap..."
        $SUDO snap install nvim --classic
    elif [[ "$OS" == "ubuntu" && $(echo "$VER >= 20.04" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
        log_info "Adding Neovim PPA for Ubuntu..."
        $SUDO add-apt-repository ppa:neovim-ppa/stable -y
        $SUDO apt-get update
        $SUDO apt-get install -y neovim
    else
        log_info "Installing Neovim from package manager..."
        $SUDO apt-get install -y neovim || {
            log_warning "Package manager version might be old, trying AppImage..."
            install_neovim_appimage
        }
    fi
}

install_neovim_appimage() {
    log_info "Installing Neovim AppImage..."
    
    mkdir -p "$HOME/.local/bin"
    
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod +x nvim.appimage
    mv nvim.appimage "$HOME/.local/bin/nvim"
    
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    log_success "Neovim AppImage installed to $HOME/.local/bin/nvim"
}

# Install luarocks from source (for older systems)
install_luarocks_from_source() {
    log_info "Installing luarocks from source..."
    
    LUAROCKS_VERSION="3.9.2"
    cd /tmp
    wget "https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz"
    tar zxpf "luarocks-${LUAROCKS_VERSION}.tar.gz"
    cd "luarocks-${LUAROCKS_VERSION}"
    
    ./configure --with-lua-include=/usr/include/lua5.3
    make
    $SUDO make install
    cd ~
}

setup_nvim_config() {
    log_info "Setting up Neovim configuration..."
    
    SRC="$(pwd)/config_src"
    TARGET="$HOME/.config/nvim"
    
    if [[ ! -d "$SRC" ]]; then
        log_error "Source directory $SRC does not exist"
        exit 1
    fi
    
    if [[ -n "$SUDO" ]]; then
        $SUDO chown -R "$(whoami):$(id -gn)" "$SRC" 2>/dev/null || true
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

setup_aliases() {
    log_info "Setting up shell aliases..."
    
    CURRENT_SHELL=$(basename "$SHELL")
    case $CURRENT_SHELL in
        bash)
            ALIAS_FILE="$HOME/.bash_aliases"
            PROFILE_FILE="$HOME/.bashrc"
            ;;
        zsh)
            ALIAS_FILE="$HOME/.zsh_aliases"
            PROFILE_FILE="$HOME/.zshrc"
            ;;
        *)
            ALIAS_FILE="$HOME/.aliases"
            PROFILE_FILE="$HOME/.profile"
            ;;
    esac
    
    touch "$ALIAS_FILE"
    
    if ! grep -q "^alias vim='nvim'" "$ALIAS_FILE" 2>/dev/null; then
        echo "alias vim='nvim'" >> "$ALIAS_FILE"
        log_success "Added alias: vim -> nvim"
    fi
    
    if command -v vim >/dev/null 2>&1; then
        NATIVE_VIM=$(command -v vim)
        NVIM_PATH=$(command -v nvim 2>/dev/null || echo "")
        
        if [[ -n "$NATIVE_VIM" && "$NATIVE_VIM" != "$NVIM_PATH" ]]; then
            if ! grep -q "^alias rvim=" "$ALIAS_FILE" 2>/dev/null; then
                echo "alias rvim='$NATIVE_VIM'" >> "$ALIAS_FILE"
                log_success "Added alias: rvim -> $NATIVE_VIM"
            fi
        fi
    fi
    
    ALIAS_SOURCE_LINE="[ -f \"$ALIAS_FILE\" ] && source \"$ALIAS_FILE\""
    if [[ -f "$PROFILE_FILE" ]] && ! grep -Fq "$ALIAS_SOURCE_LINE" "$PROFILE_FILE"; then
        echo "$ALIAS_SOURCE_LINE" >> "$PROFILE_FILE"
    fi
    
    log_info "Aliases configured in $ALIAS_FILE"
}

install_additional_tools() {
    log_info "Installing additional development tools..."
    
    case $OS in
        ubuntu|debian)
            if [[ "$OS" == "ubuntu" && $(echo "$VER >= 18.10" | bc -l 2>/dev/null || echo 0) -eq 1 ]] || 
               [[ "$OS" == "debian" && $(echo "$VER >= 11" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then
                $SUDO apt-get install -y ripgrep
            else
                install_ripgrep_manual
            fi
            ;;
        fedora|centos|rhel)
            $SUDO dnf install -y ripgrep 2>/dev/null || install_ripgrep_manual
            ;;
        arch|manjaro)
            $SUDO pacman -S --noconfirm ripgrep
            ;;
    esac
    
    case $OS in
        ubuntu|debian)
            $SUDO apt-get install -y fd-find 2>/dev/null || log_warning "fd-find not available"
            ;;
        fedora|centos|rhel)
            $SUDO dnf install -y fd-find 2>/dev/null || log_warning "fd-find not available"
            ;;
        arch|manjaro)
            $SUDO pacman -S --noconfirm fd
            ;;
    esac
}

install_ripgrep_manual() {
    log_info "Installing ripgrep manually..."
    RG_VERSION="13.0.0"
    ARCH=$(uname -m)
    
    case $ARCH in
        x86_64) RG_ARCH="x86_64" ;;
        aarch64) RG_ARCH="aarch64" ;;
        *) log_warning "Unsupported architecture for ripgrep: $ARCH"; return ;;
    esac
    
    cd /tmp
    wget "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-${RG_ARCH}-unknown-linux-musl.tar.gz"
    tar xzf "ripgrep-${RG_VERSION}-${RG_ARCH}-unknown-linux-musl.tar.gz"
    $SUDO cp "ripgrep-${RG_VERSION}-${RG_ARCH}-unknown-linux-musl/rg" /usr/local/bin/
    cd ~
}

health_check() {
    log_info "Running health check..."
    
    ISSUES=0
    
    if command -v nvim >/dev/null 2>&1; then
        NVIM_VERSION=$(nvim --version | head -n1)
        log_success "Neovim installed: $NVIM_VERSION"
    else
        log_error "Neovim not found in PATH"
        ((ISSUES++))
    fi
    
    if command -v git >/dev/null 2>&1; then
        log_success "Git installed: $(git --version)"
    else
        log_error "Git not found"
        ((ISSUES++))
    fi
    
    if [[ -L "$HOME/.config/nvim" ]]; then
        log_success "Neovim config symlink created"
    else
        log_error "Neovim config symlink not found"
        ((ISSUES++))
    fi
    
    if command -v lua >/dev/null 2>&1; then
        log_success "Lua installed: $(lua -v 2>&1 | head -n1)"
    else
        log_warning "Lua not found (optional)"
    fi
    
    if [[ $ISSUES -eq 0 ]]; then
        log_success "All checks passed! ✅"
        log_info "Please restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
    else
        log_error "$ISSUES issues found. Please review the output above."
        exit 1
    fi
}

main() {
    log_info "Starting Neovim portable IDE setup..."
    
    detect_os
    check_sudo
    install_packages
    setup_nvim_config
    setup_aliases
    install_additional_tools
    health_check
    
    log_success "Installation complete! 🎉"
    log_info "You can now use 'vim' or 'nvim' to start your portable IDE"
    log_info "Use 'rvim' if you need the original vim"
}

main "$@"
