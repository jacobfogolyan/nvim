return {
	"stevearc/oil.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("oil").setup {
			-- Takeover default netrw explorer
			default_file_explorer = true,
			columns = {
				"icon",
				"permissions",
				"size",
			},
			view_options = {
				show_hidden = true,
			}
		}

		vim.keymap.set("n", "<C-o>", "<CMD>Oil<CR>", { desc = "Open parent directory" })
	end
}

