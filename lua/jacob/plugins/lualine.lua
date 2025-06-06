return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"tpope/vim-fugitive",
		"folke/trouble.nvim",
		"folke/lazy.nvim",
	},

	config = function()
		local status = require("lazy.status")

		require("lualine").setup {
			icons_enabled = true,
			theme = "auto",
			-- Show a separate status bar per window
			globalstatus = false,
			extensions = {
				"fugitive",
				"trouble",
			},
			sections = {
				lualine_a = {
					{ "mode" },
				},
				lualine_b = {
					{ "branch" },
					{ "diff" },
					{
						"diagnostics",
						sources = { "nvim_lsp" },
						colored = true,
						always_visible = false,
					},
				},
				lualine_c = {
					{
						"filename",
						path = 1
					},
				},
				lualine_x = {
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
					{
						status.updates,
						cond = status.has_updates,
						color = { fg = "#ff9e64" }
					},
				},
				lualine_y = {
					{ "progress" }
				},
				lualine_z = {
					{ "location" },
				}
			},
		}
	end
}
