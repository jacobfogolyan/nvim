-- Performance optimizations for Neovim
-- This file contains various optimizations to improve startup and runtime performance

local M = {}

function M.setup()
	-- Disable some built-in plugins for faster startup
	local disabled_built_ins = {
		"netrw",
		"netrwPlugin",
		"netrwSettings",
		"netrwFileHandlers",
		"gzip",
		"zip",
		"zipPlugin",
		"tar",
		"tarPlugin",
		"getscript",
		"getscriptPlugin",
		"vimball",
		"vimballPlugin",
		"2html_plugin",
		"logipat",
		"rrhelper",
		"spellfile_plugin",
		"matchit",
		"tutor",
		"rplugin",
		"syntax",
		"synmenu",
		"optwin",
		"compiler",
		"bugreport",
		"ftplugin",
	}
	
	for _, plugin in pairs(disabled_built_ins) do
		vim.g["loaded_" .. plugin] = 1
	end
	
	-- Performance options
	vim.opt.lazyredraw = true -- Don't redraw while executing macros
	vim.opt.synmaxcol = 240 -- Limit syntax highlighting for long lines
	vim.opt.updatetime = 750 -- Faster completion
	vim.opt.timeoutlen = 400 -- Faster key sequence completion
	vim.opt.ttimeoutlen = 0 -- Instant insert mode exit
	vim.opt.redrawtime = 1500 -- Time in milliseconds for redrawing
	
	-- File handling optimizations
	vim.opt.undolevels = 1000 -- Limit undo levels
	vim.opt.undoreload = 10000 -- Limit undo reload
	vim.opt.maxmempattern = 2000 -- Limit memory for pattern searching
	
	-- Shada file optimizations (Neovim's viminfo)
	vim.opt.shada = "'100,<50,s10,h"
	
	-- Disable swap files for better performance (be careful with this)
	-- vim.opt.swapfile = false
	
	-- Backup optimizations
	vim.opt.backup = false
	vim.opt.writebackup = false
	
	-- Folding optimizations
	vim.opt.foldmethod = "manual" -- Manual folding is faster than syntax
	vim.opt.foldlevelstart = 99 -- Start with all folds open
	
	-- Better regex engine
	vim.opt.regexpengine = 1 -- Use old regex engine (often faster)
	
	-- Disable cursorline in insert mode for better performance
	vim.api.nvim_create_autocmd({ "InsertEnter" }, {
		pattern = "*",
		callback = function()
			vim.opt.cursorline = false
		end,
	})
	
	vim.api.nvim_create_autocmd({ "InsertLeave" }, {
		pattern = "*",
		callback = function()
			vim.opt.cursorline = true
		end,
	})
	
	-- Defer loading of clipboard providers
	vim.g.loaded_clipboard_provider = 1
	
	-- Optimize for large files
	vim.api.nvim_create_autocmd({ "BufReadPre" }, {
		pattern = "*",
		callback = function()
			local max_filesize = 100 * 1024 * 1024 -- 100 MB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
			if ok and stats and stats.size > max_filesize then
				vim.b.large_file = true
				vim.cmd("syntax off")
				vim.opt_local.swapfile = false
				vim.opt_local.bufhidden = "unload"
				vim.opt_local.undolevels = -1
				vim.opt_local.undoreload = 0
				vim.opt_local.list = false
			end
		end,
	})
	
	-- Garbage collection optimization
	vim.opt.updatetime = 750
	vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
		pattern = "*",
		callback = function()
			if #vim.tbl_keys(vim.lsp.buf_get_clients()) == 0 then
				vim.b.lsp_active = false
			end
		end,
	})
end

return M