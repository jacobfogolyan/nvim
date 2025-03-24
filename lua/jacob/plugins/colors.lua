return {
	--{
	--	-- string is github url without gihub.com at start{
	--	"catppuccin/nvim",
	--  enabled = false,
	--	config = function()
	--		require("catppuccin").setup({
	--			flavour = "mocha",
	--		})
	--		vim.cmd.colorscheme "catppuccin"
	--	end
	--},
	{
		"gmr458/vscode_modern_theme.nvim",
		lazy = false,
		enabled = false,
		priority = 1000,
		config = function()
			require("vscode_modern").setup({
				cursorline = true,
				transparent_background = false,
				nvim_tree_darker = true,
			})
			vim.cmd.colorscheme("vscode_modern")
		end,
	},
	{
		"EdenEast/nightfox.nvim",
		enabled = true,
		lazy = false,
		config = function()
			require("nightfox").setup {
				options = {
					transparent = false,
					modules = {
						diagnostic = {
							enable = true,
						},
						native_lsp = {
							enable = true,
						},
						treesitter = true,
						barbar = false,
						cmp = true,
						fidget = true,
						gitgutter = true,
						gitsigns = true,
						illuminate = true,
						indent_blankline = true,
						lazy = true,
						leap = {
							enable = true,
							background = false,
							harsh = true,
						},
						modes = true,
						neotest = true,
						notify = true,
						telescope = true,
					},
				}
			};

			vim.cmd("colorscheme carbonfox")
		end
	},
	-- lazy
	--{
	--    "sontungexpt/witch",
	--    priority = 1000,
	--    lazy = false,
	--    config = function(_, opts)
	--        require("witch").setup(opts)
	--    end,
	--}
}
