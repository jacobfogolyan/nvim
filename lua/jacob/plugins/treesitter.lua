return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function ()
		---@diagnostic disable-next-line: missing-fields
		require("nvim-treesitter.configs").setup({
			-- A list of parser names, or "all" (the five listed parsers should always be installed)
			-- https://github.com/nvim-treesitter/nvim-treesitter
			ensure_installed = {
				"bash",
				"comment",
				"typescript",
				"make",
				"dockerfile",
				"vim",
				"vimdoc",
				"query",
				"toml",
				"yaml",
				"json",
				"gitcommit",
				"gitignore",
				"fish",
				"css",
				"lua",
				"vue",
				"javascript",
				"tsx",
				"prisma",
			},

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
			auto_install = false,

			highlight = {
				enable = true,

				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = false,
			},
		})

	end
}
