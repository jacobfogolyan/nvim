-- Professional UI settings for comfortable all-day coding
-- Optimized for readability and reduced eye strain

local M = {}

function M.setup()
	-- Font and display settings for better readability
	if vim.fn.has("gui_running") == 1 or vim.fn.exists("g:neovide") == 1 then
		vim.o.guifont = "CaskaydiaCove Nerd Font:h14" -- Professional coding font
		vim.g.neovide_transparency = 0.95
		vim.g.neovide_floating_blur_amount_x = 2.0
		vim.g.neovide_floating_blur_amount_y = 2.0
		vim.g.neovide_scroll_animation_length = 0.3
		vim.g.neovide_cursor_animation_length = 0.13
		vim.g.neovide_cursor_trail_size = 0.8
		vim.g.neovide_cursor_vfx_mode = "railgun"
	end

	-- Optimal spacing and layout
	vim.opt.linespace = 2                -- Add slight line spacing for better readability
	vim.opt.pumheight = 12               -- Limit popup menu height
	vim.opt.pumblend = 10                -- Slight transparency for popup menus
	vim.opt.winblend = 10                -- Slight transparency for floating windows
	
	-- Better split window borders
	vim.opt.fillchars:append({
		horiz = "━",
		horizup = "┻",
		horizdown = "┳",
		vert = "┃",
		vertleft = "┫",
		vertright = "┣",
		verthoriz = "╋",
		eob = " ",                       -- Hide ~ at end of buffer
	})

	-- Smooth scrolling settings
	vim.opt.smoothscroll = true          -- Enable smooth scrolling (Neovim 0.9+)
	vim.opt.scrolloff = 8                -- Keep 8 lines above/below cursor
	vim.opt.sidescrolloff = 8            -- Keep 8 columns left/right of cursor
	
	-- Better search highlighting
	vim.opt.hlsearch = true
	vim.opt.incsearch = true
	vim.opt.ignorecase = true
	vim.opt.smartcase = true
	
	-- Visual feedback improvements
	vim.opt.showmatch = true             -- Highlight matching brackets
	vim.opt.matchtime = 2                -- Tenths of second to show match
	vim.opt.list = true                  -- Show invisible characters
	vim.opt.listchars = {
		tab = "→ ",
		trail = "·",
		extends = "»",
		precedes = "«",
		nbsp = "␣",
	}
	
	-- Cursor and line settings
	vim.opt.cursorline = true            -- Highlight current line
	vim.opt.cursorlineopt = "both"       -- Highlight both line number and text
	vim.opt.guicursor = {
		"n-v-c:block-Cursor/lCursor",
		"i-ci-ve:ver25-Cursor/lCursor",
		"r-cr:hor20-Cursor/lCursor",
		"o:hor50",
		"a:blinkwait700-blinkoff400-blinkon250",
		"sm:block-blinkwait175-blinkoff150-blinkon175",
	}
	
	-- Professional colorcolumn for line length guide
	vim.opt.colorcolumn = "80,120"       -- Guide at 80 and 120 characters
	vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#1f2030" })
	
	-- Better completion experience
	vim.opt.completeopt = { "menu", "menuone", "noselect", "preview" }
	vim.opt.shortmess:append("c")        -- Don't show completion messages
	
	-- Sign column always visible to prevent jumping
	vim.opt.signcolumn = "yes:2"         -- Always show sign column with space for 2 signs
	vim.opt.number = true                -- Show line numbers
	vim.opt.relativenumber = true        -- Relative line numbers
	vim.opt.numberwidth = 4              -- Minimum number column width
	
	-- Tab and indentation (optimized for most languages)
	vim.opt.expandtab = false            -- Use tabs
	vim.opt.tabstop = 4                  -- Tab width
	vim.opt.shiftwidth = 4               -- Indent width
	vim.opt.softtabstop = 4              -- Soft tab width
	vim.opt.smartindent = true           -- Smart indentation
	vim.opt.breakindent = true           -- Maintain indent on wrapped lines
	vim.opt.linebreak = true             -- Break at word boundaries
	
	-- Window title for better context
	vim.opt.title = true
	vim.opt.titlestring = "%<%F%=%l/%L - nvim"
	
	-- Mouse support for convenience
	vim.opt.mouse = "a"
	vim.opt.mousemodel = "popup"
	
	-- Faster UI updates
	vim.opt.updatetime = 100             -- Faster completion
	vim.opt.redrawtime = 1500            -- Time in milliseconds for redrawing
	vim.opt.timeoutlen = 300             -- Faster key sequence completion
	vim.opt.ttimeoutlen = 10             -- Faster escape key response
	
	-- Better undo/redo
	vim.opt.undofile = true              -- Persistent undo
	vim.opt.undolevels = 10000           -- Maximum undo levels
	vim.opt.undoreload = 10000           -- Save undo on reload if lines < 10000
	
	-- Split windows in a more natural way
	vim.opt.splitbelow = true            -- Horizontal splits below
	vim.opt.splitright = true            -- Vertical splits to the right
	vim.opt.splitkeep = "screen"         -- Keep screen position when splitting
	
	-- Disable annoying sounds
	vim.opt.errorbells = false
	vim.opt.visualbell = false
	
	-- Better diff mode
	vim.opt.diffopt:append({
		"internal",
		"filler",
		"closeoff",
		"hiddenoff",
		"algorithm:patience",
		"linematch:60",
	})
	
	-- Fold settings (managed by nvim-ufo)
	vim.opt.foldmethod = "expr"
	vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
	
	-- Set leader key
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "
	
	-- Autocommands for better UX
	local augroup = vim.api.nvim_create_augroup("UISettings", { clear = true })
	
	-- Highlight yanked text
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = augroup,
		pattern = "*",
		callback = function()
			vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
		end,
	})
	
	-- Auto-resize splits when window is resized
	vim.api.nvim_create_autocmd("VimResized", {
		group = augroup,
		pattern = "*",
		command = "wincmd =",
	})
	
	-- Remove trailing whitespace on save
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = augroup,
		pattern = "*",
		callback = function()
			local save_cursor = vim.fn.getpos(".")
			vim.cmd([[%s/\s\+$//e]])
			vim.fn.setpos(".", save_cursor)
		end,
	})
	
	-- Return to last edit position when opening files
	vim.api.nvim_create_autocmd("BufReadPost", {
		group = augroup,
		pattern = "*",
		callback = function()
			local mark = vim.api.nvim_buf_get_mark(0, '"')
			local lcount = vim.api.nvim_buf_line_count(0)
			if mark[1] > 0 and mark[1] <= lcount then
				pcall(vim.api.nvim_win_set_cursor, 0, mark)
			end
		end,
	})
end

return M