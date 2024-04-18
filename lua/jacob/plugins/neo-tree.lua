return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		"3rd/image.nvim",        -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	config = function()
		vim.keymap.set('n', '<leader>n', '<cmd>Neotree toggle<cr>');
		vim.keymap.set('n', '<leader>nf', '<cmd>Neotree focus<cr>');

		require("neo-tree").setup({
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
				}
			},
			enable_git_status = true,
			enable_diagnostics = true,
			git_status = {
				symbols = {
					-- Change type
					added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
					modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
					deleted   = "✖", -- this can only be used in the git_status source
					renamed   = "󰁕", -- this can only be used in the git_status source
					-- Status type
					untracked = "",
					ignored   = "",
					unstaged  = "󰄱",
					staged    = "",
					conflict  = "",
				},
			},
			window = {
				width = 40,
			}
		})
	end
}
