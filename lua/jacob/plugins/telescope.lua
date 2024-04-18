return {
	"nvim-telescope/telescope.nvim",
	tag = '0.1.6',
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local telescope = require("telescope")
		telescope.setup {
			-- extra setup options, integrate with other plugins etc	
		}

		local builtin = require("telescope.builtin")

		local function customFindFiles()
			builtin.find_files({
				find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
				previewer = false,
			})
		end

		vim.keymap.set("n", "<leader>f", customFindFiles, {})
		-- <C-f> needs ripgrep
		vim.keymap.set("n", "<leader>F", builtin.live_grep, {})
		vim.keymap.set("n", "<leader>b", builtin.buffers, {})
		vim.keymap.set("n", "<C-k>", "<C-p>")
	end
}
