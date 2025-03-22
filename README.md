# Neovim Configuration Guide

## Editor Settings
- **Basic Settings**:
  - Uses spaces instead of tabs (expandtab)
  - Tab width: 2 spaces
  - Relative line numbers enabled
  - Smart indentation
  - Word wrap disabled
  - No swap files or backups
  - Undodir for persistent undo history
  - Termguicolors enabled for better color support
  - Scrolloff: 8 lines (keeps cursor away from screen edge)
  - Fast updatetime (50ms) for better responsiveness

## Key Mappings

### General
- **Leader Key**: Space
- `<Space><Space>` - Source current file
- `<Space>pv` - Open file explorer (Neotree)
- `<Space>+` - Toggle between full width and half width for current window
- `<Esc>` in terminal mode - Exit terminal mode

### Navigation
- `<C-h/j/k/l>` - Navigate between splits/tmux panes
- `<C-d>/<C-u>` - Scroll down/up (with centering)
- `<C-f>` - Open tmux sessionizer
- `n/N` - Next/previous search result (with centering)

### Text Manipulation
- `J` (normal mode) - Join lines
- `J/K` (visual mode) - Move selected lines down/up
- `<Space>p` (visual mode) - Paste without losing register contents
- `<Space>y` - Yank to system clipboard
- `<Space>Y` - Yank line to system clipboard
- `<Space>d` - Delete without storing in register
- `<Space>s` - Search and replace word under cursor
- `<Space>x` - Make current file executable

### LSP and Code Navigation
- `gd` - Go to definition
- `K` - Show hover information
- `<Space>vws` - Workspace symbol search
- `<Space>vd` - Show diagnostics in float
- `<Space>vca` - Code action
- `<Space>vrr` - Show references
- `<Space>vrn` - Rename
- `<C-h>` (insert mode) - Show signature help
- `[d]/]d` - Go to previous/next diagnostic
- `<Space>f` - Format code
- `<Space>zig` - Restart LSP

### Error Navigation
- `<C-k>/<C-j>` - Next/previous quickfix item
- `<Space>k/<Space>j` - Next/previous location list item

### Telescope (Fuzzy Finder)
- `<Space>pf` - Find files
- `<C-p>` - Git files
- `<Space>pws` - Search for word under cursor
- `<Space>pWs` - Search for WORD under cursor
- `<Space>ps` - Grep search
- `<Space>vh` - Help tags
- `<Space>b` - Buffers

### Go Specific
- `<Space>ee` - Insert error handling snippet
- `<Space>ea` - Insert assert.NoError snippet
- `<Space>ef` - Insert fatal error handling snippet
- `<Space>el` - Insert logger error snippet

## Plugins

### Core
- **lazy.nvim** - Plugin manager
- **plenary.nvim** - Lua utilities

### UI
- **rose-pine/neovim** - Primary color scheme (rose-pine-moon with transparent background)
- **tokyonight.nvim** - Alternative color scheme
- **gruvbox.nvim** - Alternative color scheme
- **brightburn.vim** - Alternative color scheme
- **fidget.nvim** - LSP progress display

### Navigation and File Management
- **neo-tree.nvim** - File explorer (floating mode)
- **telescope.nvim** - Fuzzy finder
- **vim-tmux-navigator** - Seamless navigation between Vim and tmux panes

### Language Support
- **nvim-treesitter** - Syntax highlighting and code understanding
  - Supports: JavaScript, TypeScript, C, Lua, Rust, JSDoc, Bash, and more
  - Custom parser for templ files

### LSP and Completion
- **nvim-lspconfig** - LSP configuration
- **mason.nvim** - LSP/DAP/linter installer
- **mason-lspconfig.nvim** - Integration between mason and lspconfig
- **conform.nvim** - Formatter
- **nvim-cmp** - Completion engine
  - With sources for LSP, buffer, path, cmdline, snippets
- **LuaSnip** - Snippet engine

## Auto Commands
- Highlight yanked text
- Remove trailing whitespace on save
- Apply colorscheme on buffer enter
- Setup LSP keybindings when LSP attaches

## LSP Configuration
- **Ensured servers**:
  - lua_ls (with Lua 5.1 runtime)
  - rust_analyzer
  - gopls
- **Custom configured servers**:
  - zls (Zig Language Server)

## Adding New Plugins

To add a new plugin, create or edit a file in `~/.config/nvim/lua/sektor/lazy/` directory.

Example structure:
```lua
return {
  {
    "username/repo-name",
    config = function()
      require("plugin-name").setup({
        -- configuration options
      })
    end,
    -- Other options like dependencies, lazy-loading etc.
  }
}
```

## Special Features
- Auto-removal of trailing whitespace
- Special handling for templ files
- Syntax highlighting disabling for large files (>100KB)
- Netrw configuration (list style, banner disabled)
