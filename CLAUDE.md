# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal Neovim configuration repository using Lua. The configuration follows a modular structure with Lazy.nvim as the plugin manager and includes 33+ plugins for development across multiple languages.

## Architecture

### Core Structure
```
init.lua                    # Entry point, loads jacob module
lua/jacob/
├── init.lua               # Loads remap, config, lazy, and commands
├── config.lua             # Core Neovim settings (tabs, UI, behavior)
├── remap.lua              # Custom keymappings (leader = space)
├── lazy.lua               # Lazy.nvim bootstrap and configuration
├── lua/commands.lua       # Custom commands (AllEntities)
└── plugins/               # Individual plugin configurations (33 files)
```

### Plugin Management
- **Manager**: Lazy.nvim with automatic installation
- **Pattern**: Each plugin has its own file in `lua/jacob/plugins/`
- **Loading**: Lazy loading with event triggers (BufReadPre, InsertEnter, etc.)
- **Updates**: Automatic checking every 48 hours

### Key Configuration Patterns

1. **LSP Setup**: Uses Mason for automatic LSP installation with mason-lspconfig bridge
2. **Formatting**: Dual system - ESLint LSP + formatter.nvim (Prettier)
3. **Completion**: nvim-cmp with multiple sources (LSP, Copilot, buffer, path)
4. **Git Integration**: Fugitive + Gitsigns for comprehensive Git workflow
5. **File Navigation**: Telescope + Oil.nvim for fuzzy finding and file management

## Common Development Tasks

### Reload Configuration
```vim
:so                        " Reload current file
<leader><leader>          " Mapped to reload
```

### Plugin Management
```vim
:Lazy                     " Open Lazy.nvim interface
:Lazy sync                " Update all plugins
:Lazy install             " Install missing plugins
:Mason                    " Manage LSP servers
```

### LSP Operations
```vim
K                         " Hover documentation
gd                        " Go to definition (in vsplit)
gr                        " Go to references (in vsplit)
<F2>                      " Rename symbol
<leader>a                 " Code actions
<leader>T                 " Format buffer
fb                        " Format buffer (async)
```

### File Navigation
```vim
<leader>pf                " Find files (Telescope)
<C-p>                     " Git files (Telescope)
<leader>ps                " Grep search (Telescope)
<leader>vh                " Help tags (Telescope)
-                         " Open Oil file manager
```

## Language-Specific Configuration

### TypeScript/JavaScript/Vue
- **LSP**: ts_ls for TS/JS, Volar for Vue (with Nuxt support)
- **Formatting**: Prettier via formatter.nvim
- **Linting**: ESLint LSP (disabled formatting to avoid conflicts)
- **Root Detection**: Prioritizes tsconfig.json, then package.json

### Go
- **LSP**: gopls with gofumpt, staticcheck, and field alignment
- **Error Snippet**: `<leader>ee` inserts error handling

### Lua
- **LSP**: lua_ls with Neovim API support via lazydev.nvim
- **Formatting**: Stylua

## Dependencies

Required system dependencies:
- `ripgrep` - For Telescope grep functionality
- `node` and `npm` - For JS/TS tooling
- `neovim` npm package - For Node provider
- `deno` - For certain plugins
- Nerd Font (CascadiaMono recommended) - For icons

## Important Keybindings

- **Leader**: Space
- **System Clipboard**: `<leader>y` (yank), `<leader>p` (paste)
- **Window Navigation**: Uses tmux-navigator bindings
- **Buffer Management**: `<leader>q` (close), `<leader>bd` (delete and go to previous)
- **Terminal**: `<leader>t` (open terminal in current file's directory)

## Plugin-Specific Notes

### Formatter.nvim
- Auto-formats on save for: vue, js, jsx, ts, tsx, py, html, css, scss, mjs, yml, json, cpp
- Bypass with `:W` command (saves without formatting)

### Oil.nvim
- Modified to open all files in buffers when selecting multiple
- Use `-` to open in current directory

### Copilot
- Integrated with nvim-cmp for inline suggestions
- Separate Copilot Chat functionality available

### Avante & CodeCompanion
- AI assistance plugins configured for code generation and chat

## Troubleshooting Common Issues

### Formatting Issues
1. Check if ESLint config exists in project (`.eslintrc*`, `eslint.config.*`)
2. Verify Prettier is installed globally or in project
3. Use `:Mason` to ensure eslint and typescript-language-server are installed
4. Check `:LspInfo` for active LSP clients

### LSP Not Working
1. Run `:Mason` and install required servers
2. Check `:checkhealth` for provider issues
3. Verify project has proper root markers (package.json, tsconfig.json)

### Plugin Issues
1. Run `:Lazy sync` to update plugins
2. Check `:Lazy log` for installation errors
3. Delete `~/.local/share/nvim/lazy` and restart to clean install

## Configuration Philosophy

- **Modular**: Each plugin/feature in separate file for maintainability
- **Performance**: Lazy loading, disabled unused built-in plugins
- **IDE-like**: Full LSP support with formatting, linting, and completion
- **Git-centric**: Deep Git integration for development workflow
- **Keyboard-driven**: Minimal mouse usage, extensive keybindings