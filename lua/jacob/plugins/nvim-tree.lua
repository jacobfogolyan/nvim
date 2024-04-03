return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup {
			sort = {
				sorter = "name",
				folders_first = true,
				files_first = false,
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
