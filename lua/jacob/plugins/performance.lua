-- Performance optimizations for Neovim
return {
	-- Faster file type detection
	{ "nathom/filetype.nvim", lazy = false, priority = 100 },

	-- Better buffer deletion without messing up window layout
	{
		"famiu/bufdelete.nvim",
		cmd = { "Bdelete", "Bwipeout" },
		keys = {
			{
				"<leader>q",
				function()
					local buf_name = vim.api.nvim_buf_get_name(0)
					local buf_type = vim.bo.buftype
					local file_type = vim.bo.filetype
					local window_count = #vim.api.nvim_list_wins()

					-- Check if Fugitive is open in another window
					local fugitive_open = false
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local win_buf = vim.api.nvim_win_get_buf(win)
						local win_ft = vim.api.nvim_buf_get_option(win_buf, "filetype")
						if win_ft == "fugitive" then
							fugitive_open = true
							break
						end
					end

					-- If we're in a normal file but Fugitive is open in another window,
					-- just close this window (likely opened from Fugitive)
					if fugitive_open and file_type ~= "fugitive" and buf_type == "" then
						vim.cmd("close")
						-- Check if it's a special buffer that should close the window
					elseif file_type == "fugitive" or
						file_type == "gitcommit" or
						buf_type == "help" or
						buf_type == "quickfix" or
						buf_type == "nofile" or
						buf_name:match("^fugitive://") then
						-- If it's the last window, use Bdelete instead of close
						if window_count == 1 then
							vim.cmd("Bdelete")
						else
							vim.cmd("close")
						end
					else
						-- Use Bdelete for normal file buffers
						vim.cmd("Bdelete")
					end
				end,
				desc = "Smart buffer/window close"
			},
			{ "<leader>Q", "<cmd>Bdelete!<CR>", desc = "Force delete buffer" },
		},
	},

	-- Automatic handling of large files
	{
		"LunarVim/bigfile.nvim",
		lazy = false,
		config = function()
			require("bigfile").setup({
				filesize = 1, -- Size in MB, files larger than this will trigger optimizations
				pattern = { "*" },
				features = {
					"indent_blankline",
					"illuminate",
					"lsp",
					"treesitter",
					"syntax",
					"matchparen",
					"vimopts",
					"filetype",
				},
			})
		end,
	},

	-- Faster project detection
	{
		"ahmedkhalf/project.nvim",
		event = "VeryLazy",
		config = function()
			require("project_nvim").setup({
				detection_methods = { "pattern", "lsp" },
				patterns = { ".git", "package.json", "tsconfig.json", "Makefile" },
				show_hidden = false,
				silent_chdir = true,
			})
		end,
	},

	-- Startup time profiler (use :StartupTime to profile)
	{
		"dstein64/vim-startuptime",
		cmd = "StartupTime",
		init = function()
			vim.g.startuptime_tries = 10
		end,
	},
}

