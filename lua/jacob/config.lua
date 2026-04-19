local config = {
	-- Allow copying to wayland clipboard
	-- clipboard = "unnamedplus",
	cmdheight = 1,
	completeopt = { "menuone", "noselect" },
	fileencoding = "utf-8",
	-- Keep multiple buffers
	hidden = true,
	-- Auto-completion time
	updatetime = 1000,
	-- Enable GUI colors
	termguicolors = true,
	-- show title in minimized window
	title = true,
	-- Disable backup files
	backup = false,
	writebackup = false,
	guicursor = "",
	-- Relative line numbering
	number = true,
	relativenumber = true,
	-- Tab settings
	tabstop = 4,
	softtabstop = 4,
	shiftwidth = 4,
	-- Ignore case sensitivity in search
	ignorecase = true,
	-- Do not convert tabs to spaces
	expandtab = false,
	-- Try to do smart indentation
	smartindent = true,
	hlsearch = true,
	incsearch = true,
	scrolloff = 8,
	sidescrolloff = 8,
	-- Always show the sign columns to avoid unnecessary text movement
	signcolumn = "yes",
	-- Rulers
	colorcolumn = "120",
	-- Highlight current line
	cursorline = true,
	-- Set number column width
	numberwidth = 4,
	-- Disable modeline
	showmode = false,
	-- Persistent undos
	undofile = true,
	-- Always show tabs
	showtabline = 2,
	-- wrap long lines
	wrap = true,
	-- Break lines at word boundaries
	linebreak = true,
}

for k, v in pairs(config) do
	vim.opt[k] = v
end

-- Hide intro screen
vim.opt.shortmess:append("I")

vim.opt.laststatus = 2
vim.opt.showmode = true
vim.o.statusline = "%f %h%m%r %=%-14.(%l,%c%V%) %P"

-- Netrw sizing
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 45

-- Always enable editorconfig
vim.g.editorconfig = true

-- Performance optimizations
-- vim.opt.lazyredraw = true -- Disabled: conflicts with Noice.nvim
vim.opt.synmaxcol = 240   -- Limit syntax highlighting for long lines
vim.opt.updatetime = 100  -- Faster completion and diagnostic messages
vim.opt.timeoutlen = 300  -- Faster key sequence completion
vim.opt.ttimeoutlen = 10  -- Faster escape key response

-- Better regex engine for performance
vim.opt.regexpengine = 1

-- Disable some built-in plugins for faster startup
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1

-- Optimize for large files
vim.g.large_file = 1048576 -- 1MB
vim.cmd([[
  augroup LargeFile
    autocmd!
    autocmd BufReadPre * if getfsize(expand("%")) > g:large_file | setlocal eventignore+=FileType | setlocal noswapfile bufhidden=unload undolevels=-1 | endif
  augroup END
]])
