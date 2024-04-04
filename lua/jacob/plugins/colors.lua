return {
	{
		-- string is github url without gihub.com at start{
		"catppuccin/nvim",
		config = function()
			require("catppuccin").setup({
				flavour = "frappe",
			})
			vim.cmd.colorscheme "catppuccin"
		end
	},
	{
		"gmr458/vscode_modern_theme.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("vscode_modern").setup({
				cursorline = true,
				transparent_background = false,
				nvim_tree_darker = true,
			})
			vim.cmd.colorscheme("vscode_modern")
		end,
	}
}
