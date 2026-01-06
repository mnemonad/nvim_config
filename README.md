# 🚀 Neovim Portable IDE

A batteries-included, cross-platform Neovim configuration that transforms any machine into a powerful development environment in minutes. Perfect for developers who work across multiple systems or need a consistent IDE experience anywhere.

![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)

## ✨ Features

### 🎯 Core IDE Capabilities
- **LSP Integration** - Intelligent code completion, diagnostics, and formatting
- **Fuzzy Finding** - Lightning-fast file and text search with Telescope
- **Git Integration** - Built-in Git commands and status with Fugitive
- **Project Navigation** - Quick file switching with Harpoon
- **Syntax Highlighting** - Tree-sitter powered syntax highlighting
- **Undo History** - Visual undo tree for complex editing sessions
- **AI Integration** - Claude-powered code assistance with CodeCompanion
- **Keybind Discovery** - Which-key shows available shortcuts as you type

### 🐚 Shell Configuration
- **Oh My Zsh** - Pre-configured with a custom theme
- **Smart Prompt** - Shows conda env, user@host, path, and git branch
- **Filtered Tree** - Tree alias that hides common noise (`node_modules`, `__pycache__`, etc.)

### 🌐 Cross-Platform Support
- **Linux** - Ubuntu, Debian (including Bookworm), Fedora, CentOS/RHEL 8+, Arch/Manjaro
- **macOS** - Intel and Apple Silicon Macs (10.15+)
- **Windows** - Windows 10/11 with winget support

### 🔧 Developer Tools
- **Language Support** - Lua, Rust, Python, JavaScript, HTML, CSS, and more
- **Smart Keybindings** - Intuitive shortcuts that enhance productivity
- **Terminal Integration** - Seamless terminal and tmux integration
- **Modern UI** - Clean nightfox theme with proper color support

## 🚀 Quick Start

### One-Line Installation

**Linux/WSL:**
```bash
git clone https://github.com/mnemonad/nvim_config.git && cd nvim_config && chmod +x install.sh && ./install.sh
```

**macOS:**
```bash
git clone https://github.com/mnemonad/nvim_config.git && cd nvim_config && chmod +x install.zsh && ./install.zsh
```

**Windows (PowerShell as Administrator):**
```powershell
git clone https://github.com/mnemonad/nvim_config.git; cd nvim_config; .\install.bat
```

### Manual Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mnemonad/nvim_config.git
   cd nvim_config
   ```

2. **Run the appropriate installer:**
   - Linux: `./install.sh`
   - macOS: `./install.zsh` 
   - Windows: `install.bat` (as Administrator)

3. **Restart your terminal** and run `vim` or `nvim`

## 📋 System Requirements

### Minimum Requirements
- **OS**: Linux (kernel 3.10+), macOS 10.15+, or Windows 10
- **RAM**: 2GB available memory
- **Storage**: 500MB free space
- **Network**: Internet connection for plugin installation

### Recommended
- **Terminal**: A modern terminal with true color support
- **Font**: Nerd Font for optimal icon display
- **Shell**: Zsh (macOS) or Bash 4+ (Linux)

## 🎮 Key Bindings

| Key Combination | Action | Mode |
|---|---|---|
| `<Space>` | Leader key | All |
| `<Leader>pv` | File explorer | Normal |
| `<Leader>pf` | Find files | Normal |
| `<Leader>ps` | Search in files | Normal |
| `<Leader>gs` | Git status | Normal |
| `<Leader>u` | Undo tree | Normal |
| `<Leader>b` | Add to Harpoon | Normal |
| `<C-e>` | Harpoon quick menu | Normal |
| `<C-h/n/s/t>` | Harpoon buffers 1-4 | Normal |
| `<Leader>f` | Format code | Normal |
| `<Leader>y` | Copy to system clipboard | Normal/Visual |
| `J/K` | Move lines up/down | Visual |
| `<Leader>?` | Show buffer keymaps | Normal |
| `<Leader>ac` | Toggle AI chat | Normal |
| `<Leader>aa` | AI actions menu | Normal/Visual |
| `<Leader>ae` | AI inline edit | Visual |
| `<Leader>st` | Search TODOs | Normal |
| `]t / [t` | Next/prev TODO comment | Normal |

## 📁 Project Structure

```
nvim_config/
├── config_src/                 # Neovim configuration
│   ├── init.lua                # Entry point
│   ├── lua/
│   │   ├── config/
│   │   │   ├── lazy.lua        # Plugin manager setup
│   │   │   ├── remap.lua       # Key bindings
│   │   │   └── set.lua         # Vim settings
│   │   └── plugins/            # Plugin configurations
│   │       ├── codecompanion.lua # AI chat integration
│   │       ├── fugitive.lua    # Git integration
│   │       ├── harpoon.lua     # File navigation
│   │       ├── indent.lua      # Indent guides & detection
│   │       ├── lsp.lua         # Language server
│   │       ├── telescope.lua   # Fuzzy finder
│   │       ├── todo-comments.lua # TODO highlighting
│   │       ├── treesitter.lua  # Syntax highlighting
│   │       ├── undotree.lua    # Undo history
│   │       └── which-key.lua   # Keybind hints
│   └── lazy-lock.json          # Plugin version lock
├── zsh_src/                    # Zsh configuration
│   ├── .zshrc                  # Shell config (symlinked)
│   └── portable-dev.zsh-theme  # Custom prompt theme
├── install.sh                  # Linux installer
├── install.zsh                 # macOS installer
├── install.bat                 # Windows installer
└── README.md                   # This file
```

## 🔧 Customization

### Adding New Plugins

1. Create a new file in `config_src/lua/plugins/`
2. Follow the Lazy.nvim plugin specification:
   ```lua
   return {
       "author/plugin-name",
       config = function()
           -- Plugin configuration
       end,
   }
   ```

### Modifying Key Bindings

Edit `config_src/lua/config/remap.lua`:
```lua
vim.keymap.set("n", "<your-key>", "<your-action>")
```

### Changing Settings

Modify `config_src/lua/config/set.lua`:
```lua
vim.opt.your_setting = value
```

### Adding Language Servers

Edit the `ensure_installed` table in `config_src/lua/plugins/lsp.lua`:
```lua
ensure_installed = {
    "lua_ls",
    "rust_analyzer",
    "pyright",
    "your_language_server",
},
```

### Configuring AI Integration

CodeCompanion requires an Anthropic API key. Add to your shell config:
```bash
export ANTHROPIC_API_KEY="your-api-key-here"
```

Get an API key at [console.anthropic.com](https://console.anthropic.com). The free tier includes starter credits.

### Customizing the Shell Prompt

Edit `zsh_src/portable-dev.zsh-theme` to modify the prompt format:
```zsh
# Current format: (conda_env) user@host:path (git_branch)
PROMPT='$(conda_prompt_info)%{$fg[cyan]%}%n@%m%{$reset_color%}:...'
```

## 🐛 Troubleshooting

### Common Issues

**Plugin installation fails:**
```bash
# Remove plugin cache and reinstall
rm -rf ~/.local/share/nvim
nvim # Plugins will reinstall automatically
```

**LSP not working:**
```bash
# Check Mason installation
:Mason
# Install language server manually if needed
```

**Symlink creation fails (Windows):**
- Run `install.bat` as Administrator
- Or enable Developer Mode in Windows Settings

**Permission errors (Linux/macOS):**
```bash
# Fix ownership
sudo chown -R $(whoami) ~/.config/nvim
```

### Getting Help

1. **Check health:** Run `:checkhealth` in Neovim
2. **View logs:** `:Lazy log` for plugin issues
3. **LSP status:** `:LspInfo` for language server problems
4. **Create an issue** on GitHub with error details

## 🤝 Contributing

We welcome contributions! Here's how to help:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** changes: `git commit -m 'Add amazing feature'`
4. **Push** to branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

### Development Guidelines

- Test on multiple platforms before submitting
- Update documentation for new features
- Follow existing code style and conventions
- Add appropriate error handling

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

**Special Thanks to [ThePrimeagen](https://github.com/ThePrimeagen)** 🎯

This configuration is heavily inspired by and based on ThePrimeagen's Neovim setup. His educational content, live coding streams, and opinionated vim workflows have been instrumental in shaping this portable IDE. If you enjoy this config, definitely check out:
- [ThePrimeagen's YouTube Channel](https://www.youtube.com/c/ThePrimeagen)
- [His Neovim configuration tutorials](https://github.com/ThePrimeagen/.dotfiles)
- The legendary vim motions and productivity tips

### Other Amazing Projects:
- [Neovim](https://neovim.io/) - The hyperextensible Vim-based text editor
- [Lazy.nvim](https://github.com/folke/lazy.nvim) - Modern plugin manager
- [Mason.nvim](https://github.com/williamboman/mason.nvim) - LSP installer
- [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
- [Harpoon](https://github.com/ThePrimeagen/harpoon) - ThePrimeagen's file navigation masterpiece
- [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) - AI-powered coding assistant
- [Which-Key.nvim](https://github.com/folke/which-key.nvim) - Keybind discovery
- [Todo-Comments.nvim](https://github.com/folke/todo-comments.nvim) - Highlight and search TODOs
- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework


---

**Made with ❤️ for developers who want their IDE everywhere**

[⬆ Back to top](#-neovim-portable-ide)
