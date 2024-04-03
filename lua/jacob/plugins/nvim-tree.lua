return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup {
			vim = {
				sorting = {
					active = true,
					method = "name_asc"
				}
			},
			filters = {
				dotfiles = false,
				custom = { '.DS_Store' }
			},
			git = {
				ignore = false
			}
		}
	end,
}
