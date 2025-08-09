# Neovim Keybindings Reference

This document tracks all keybindings to ensure consistency when switching plugins or making changes.

## IMPORTANT: Keybinding Preservation Policy

**DO NOT CHANGE EXISTING KEYBINDINGS WITHOUT EXPLICIT PERMISSION**

When replacing plugins or adding new functionality:
1. Always preserve existing keybindings
2. Map new plugin functions to the same keys
3. Document any conflicts here
4. Ask for permission before changing any binding

## Search & Navigation Keybindings

### Original Telescope Bindings (Currently mapped to fzf-lua)
| Keybinding | Function | Original Source | Current Implementation |
|------------|----------|-----------------|------------------------|
| `<leader>f` | Find files (custom) | telescope.lua:136 | fzf-lua.lua:65 |
| `<leader>F` | Live grep (custom) | telescope.lua:138 | fzf-lua.lua:66 |
| `<leader>b` | List buffers | telescope.lua:140 | fzf-lua.lua:67 |
| `<leader>r` | Show registers | telescope.lua:142 | NOT MAPPED YET |

### Additional Search Bindings (Added with fzf-lua)
| Keybinding | Function | Status |
|------------|----------|--------|
| `<leader>ps` | Grep with input | NEW - No original binding |
| `<leader>vh` | Help tags | NEW - No original binding |
| `<C-p>` | Git files | NEW - No original binding |
| `<leader>of` | Old files | NEW - No original binding |
| `<leader>sw` | Search word under cursor | NEW - No original binding |
| `<leader>sW` | Search WORD under cursor | NEW - No original binding |
| `<leader>sl` | Search in current buffer | NEW - No original binding |
| `<leader>sr` | Resume last search | NEW - No original binding |

### LSP Keybindings (from lsp.lua)
| Keybinding | Function | Source |
|------------|----------|--------|
| `K` | Hover documentation | lsp.lua:411 |
| `gd` | Go to definition (vsplit) | lsp.lua:413 |
| `gD` | Go to declaration (vsplit) | lsp.lua:414 |
| `gi` | Go to implementation (vsplit) | lsp.lua:415 |
| `go` | Go to type definition (vsplit) | lsp.lua:416 |
| `gr` | Go to references (vsplit) | lsp.lua:417 |
| `gs` | Signature help (vsplit) | lsp.lua:418 |
| `<F2>` | Rename symbol | lsp.lua:419 |
| `fb` | Format buffer (async) | lsp.lua:420 |
| `<leader>a` | Code actions | lsp.lua:423 |
| `<leader>T` | Format buffer | lsp.lua:426 |

### Core Editor Keybindings (from remap.lua)
| Keybinding | Function | Source |
|------------|----------|--------|
| `<leader>pv` | File explorer (Ex) | remap.lua:3 |
| `<leader>y` | Yank to system clipboard | remap.lua:25,63 |
| `<leader>Y` | Yank line to system clipboard | remap.lua:26,65 |
| `<leader>p` | Paste from system clipboard | remap.lua:22 |
| `<leader>d` | Delete without yanking | remap.lua:28 |
| `<leader>f` | Format with LSP | remap.lua:35 |
| `<leader>s` | Search and replace word | remap.lua:42 |
| `<leader>x` | Make file executable | remap.lua:43 |
| `<leader>q` | Smart close (window for special buffers, buffer for files) | performance.lua:11-31 |
| `<leader>bd` | Delete buffer and go to previous | remap.lua:89 |
| `<leader>t` | Open terminal in file's directory | remap.lua:81 |
| `<leader><leader>` | Source current file | remap.lua:58 |

### Movement & Navigation (from remap.lua)
| Keybinding | Function | Source |
|------------|----------|--------|
| `J` (visual) | Move line down | remap.lua:5 |
| `K` (visual) | Move line up | remap.lua:6 |
| `J` (normal) | Join lines (cursor stays) | remap.lua:8 |
| `<C-d>` | Half page down (centered) | remap.lua:9 |
| `<C-u>` | Half page up (centered) | remap.lua:10 |
| `n` | Next search (centered) | remap.lua:11 |
| `N` | Previous search (centered) | remap.lua:12 |
| `<C-k>` | Next quickfix | remap.lua:37 |
| `<C-j>` | Previous quickfix | remap.lua:38 |
| `<leader>k` | Next location list | remap.lua:39 |
| `<leader>j` | Previous location list | remap.lua:40 |

## Plugin-Specific Bindings

### Oil.nvim (File Manager)
| Keybinding | Function | Source |
|------------|----------|--------|
| `-` | Open Oil file manager | oil.lua |

### Fugitive (Git)
| Keybinding | Function | Source |
|------------|----------|--------|
| `<leader>gs` | Git status | fugitive.lua |

### Trouble.nvim
| Keybinding | Function | Source |
|------------|----------|--------|
| `<leader>tt` | Toggle trouble | trouble.lua |

## Conflicts & Notes

1. **`<leader>gs` Conflict**: 
   - Fugitive uses it for Git status
   - fzf-lua wants to use it for Git status too
   - Resolution: Keep Fugitive binding, use different key for fzf-lua git status

2. **`<leader>r` Missing**:
   - Telescope had this for registers
   - Need to add to fzf-lua configuration

3. **`K` in visual mode**:
   - Used for moving lines up in remap.lua
   - Also used for hover in LSP (normal mode only, so no conflict)

## Guidelines for Future Changes

1. **Before changing any keybinding**: Check this file first
2. **When adding new plugins**: Map to unused keys or ask for permission
3. **When replacing plugins**: Preserve ALL existing keybindings
4. **Document changes**: Update this file immediately after any changes
5. **Conflict resolution**: Always ask user before resolving conflicts