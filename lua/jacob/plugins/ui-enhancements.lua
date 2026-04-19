-- Additional UI enhancements for professional coding experience
return {
	-- Highlight word under cursor throughout the buffer
	{
		"RRethy/vim-illuminate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("illuminate").configure({
				providers = {
					"lsp",
					"treesitter",
					"regex",
				},
				delay = 100,
				filetype_overrides = {},
				filetypes_denylist = {
					"dirvish",
					"fugitive",
					"alpha",
					"NvimTree",
					"packer",
					"neogitstatus",
					"Trouble",
					"lir",
					"Outline",
					"spectre_panel",
					"toggleterm",
					"DressingSelect",
					"TelescopePrompt",
				},
				under_cursor = true,
				large_file_cutoff = nil,
				large_file_overrides = nil,
				min_count_to_highlight = 1,
			})
			
			-- Custom highlighting for illuminated words
			vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#2a2b3d", underline = false })
			vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#2a2b3d", underline = false })
			vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#3d2a2a", underline = false })
		end,
	},

	-- Better cursor visibility with multiple cursors support
	{
		"mg979/vim-visual-multi",
		lazy = false,
		init = function()
			vim.g.VM_theme = "codedark"
			vim.g.VM_highlight_matches = "underline"
			vim.g.VM_show_warnings = 0
			vim.g.VM_silent_exit = 1
			vim.g.VM_quit_after_leaving_insert_mode = 0
			
			-- Better colors for multiple cursors
			vim.api.nvim_set_hl(0, "VM_Mono", { fg = "#ffc777", bg = "#3d4a5d", bold = true })
			vim.api.nvim_set_hl(0, "VM_Extend", { fg = "#82aaff", bg = "#2a3d5d", bold = true })
			vim.api.nvim_set_hl(0, "VM_Cursor", { fg = "#1a1b26", bg = "#ffc777", bold = true })
			vim.api.nvim_set_hl(0, "VM_Insert", { fg = "#1a1b26", bg = "#c3e88d", bold = true })
		end,
	},

	-- Color highlighter for CSS/HTML/Config files
	{
		"NvChad/nvim-colorizer.lua",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("colorizer").setup({
				filetypes = {
					"*", -- Highlight all files, but customize some
					css = { rgb_fn = true }, -- Enable CSS rgb() and rgba() functions
					html = { mode = "foreground" },
				},
				user_default_options = {
					RGB = true,
					RRGGBB = true,
					names = false, -- Don't highlight color names like Blue or red
					RRGGBBAA = true,
					AARRGGBB = false,
					rgb_fn = true,
					hsl_fn = true,
					css = true,
					css_fn = true,
					mode = "background",
					tailwind = true,
					sass = { enable = true, parsers = { "css" } },
					virtualtext = "■",
					always_update = false,
				},
				buftypes = {
					"*",
					"!prompt",
					"!popup",
				},
			})
		end,
	},

	-- Better folding with modern UI
	{
		"kevinhwang91/nvim-ufo",
		dependencies = {
			"kevinhwang91/promise-async",
		},
		event = "BufReadPost",
		config = function()
			-- Basic fold settings
			vim.o.foldcolumn = "1"
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			-- Using ufo provider need remap `zR` and `zM`
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
			
			-- Peek folded lines (but don't override K globally)
			vim.keymap.set("n", "zK", function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end, { desc = "Peek fold or hover" })

			require("ufo").setup({
				provider_selector = function(bufnr, filetype, buftype)
					-- Use LSP first, then indent as fallback
					return { "lsp", "indent" }
				end,
				preview = {
					win_config = {
						border = "rounded",
						winhighlight = "Normal:Folded",
						winblend = 0,
					},
				},
			})
			
			-- Better fold colors
			vim.api.nvim_set_hl(0, "Folded", { bg = "#1f2030", fg = "#5a5b6e" })
			vim.api.nvim_set_hl(0, "FoldColumn", { bg = "NONE", fg = "#5a5b6e" })
		end,
	},

	-- Smooth cursor animations (DISABLED - commented out to remove cursor trail effect)
	-- {
	-- 	"gen740/SmoothCursor.nvim",
	-- 	event = "VeryLazy",
	-- 	config = function()
	-- 		require("smoothcursor").setup({
	-- 			type = "default",
	-- 			cursor = "",
	-- 			texthl = "SmoothCursor",
	-- 			linehl = nil,
	-- 			fancy = {
	-- 				enable = true,
	-- 				head = { cursor = "▷", texthl = "SmoothCursor", linehl = nil },
	-- 				body = {
	-- 					{ cursor = "●", texthl = "SmoothCursorRed" },
	-- 					{ cursor = "●", texthl = "SmoothCursorOrange" },
	-- 					{ cursor = "•", texthl = "SmoothCursorYellow" },
	-- 					{ cursor = "•", texthl = "SmoothCursorGreen" },
	-- 					{ cursor = "‧", texthl = "SmoothCursorAqua" },
	-- 					{ cursor = ".", texthl = "SmoothCursorBlue" },
	-- 					{ cursor = ".", texthl = "SmoothCursorPurple" },
	-- 				},
	-- 				tail = { cursor = nil, texthl = "SmoothCursor" },
	-- 			},
	-- 			flyin_effect = nil,
	-- 			speed = 25,
	-- 			intervals = 35,
	-- 			priority = 10,
	-- 			timeout = 3000,
	-- 			threshold = 3,
	-- 			disable_float_win = false,
	-- 			enabled_filetypes = nil,
	-- 			disabled_filetypes = { "TelescopePrompt", "NvimTree", "alpha" },
	-- 		})
	-- 		
	-- 		-- Set cursor colors
	-- 		vim.api.nvim_set_hl(0, "SmoothCursor", { fg = "#ffc777" })
	-- 		vim.api.nvim_set_hl(0, "SmoothCursorRed", { fg = "#ff757f" })
	-- 		vim.api.nvim_set_hl(0, "SmoothCursorOrange", { fg = "#ff966c" })
	-- 		vim.api.nvim_set_hl(0, "SmoothCursorYellow", { fg = "#ffc777" })
	-- 		vim.api.nvim_set_hl(0, "SmoothCursorGreen", { fg = "#c3e88d" })
	-- 		vim.api.nvim_set_hl(0, "SmoothCursorAqua", { fg = "#86e1fc" })
	-- 		vim.api.nvim_set_hl(0, "SmoothCursorBlue", { fg = "#82aaff" })
	-- 		vim.api.nvim_set_hl(0, "SmoothCursorPurple", { fg = "#c099ff" })
	-- 	end,
	-- },

	-- Git signs with better visibility
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				signcolumn = true,
				numhl = false,
				linehl = false,
				word_diff = false,
				watch_gitdir = {
					interval = 1000,
					follow_files = true,
				},
				attach_to_untracked = true,
				current_line_blame = false,
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol",
					delay = 1000,
					ignore_whitespace = false,
				},
				current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
				sign_priority = 6,
				update_debounce = 100,
				status_formatter = nil,
				max_file_length = 40000,
				preview_config = {
					border = "single",
					style = "minimal",
					relative = "cursor",
					row = 0,
					col = 1,
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true })

					map("n", "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true })

					-- Actions
					map("n", "<leader>hs", gs.stage_hunk)
					map("n", "<leader>hr", gs.reset_hunk)
					map("v", "<leader>hs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("v", "<leader>hr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("n", "<leader>hS", gs.stage_buffer)
					map("n", "<leader>hu", gs.undo_stage_hunk)
					map("n", "<leader>hR", gs.reset_buffer)
					map("n", "<leader>hp", gs.preview_hunk)
					map("n", "<leader>hb", function()
						gs.blame_line({ full = true })
					end)
					map("n", "<leader>tb", gs.toggle_current_line_blame)
					map("n", "<leader>hd", gs.diffthis)
					map("n", "<leader>hD", function()
						gs.diffthis("~")
					end)
					map("n", "<leader>td", gs.toggle_deleted)
				end,
			})
			
			-- Better git sign colors
			vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#c3e88d" })
			vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#82aaff" })
			vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#ff757f" })
		end,
	},
}